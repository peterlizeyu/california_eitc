/*program to choose the number of Randomizations */
/*-----------------------------------------------*/
capture program drop CHOOSER
program define CHOOSER, rclass

	cap drop temp_g

	local group "`1'"
	local G1 `2'
	local R `3'
	
	qui egen temp_g = group(`group')
	qui summ temp_g
	local G = r(max)
	
	local permute = 0
	
	local r= round(exp(lnfactorial(`G')),1) / ((round(exp(lnfactorial(`G1')),1))*round(exp(lnfactorial(`G'-`G1')),1))
	
	if ( `r' < `R' ) {
		local R = `r '
		local permute = 1
		}

	return scalar r = `R'
	return scalar permute = `permute'
	return scalar G  = `G'
	
end /*end of CHOOSER program */
/*--------------------------------------*/

/*program to choose the pretend treated */
/*-----------------------------------------------*/
capture program drop PTREAT
program define PTREAT, rclass
	
	local G `1'
	local G1 `2'
	local R `3'
	
	*disp "G " `G'
	*disp "G1 " `G1 '
	*disp "R " `R'
	
	
	
	mata: ptreat = J(`G1',`G',.)
	
	mata: n = J(1,1,1::`G')  
	
	forvalues i = 1/`G' {
	
		mata: x = rnormal(`G',1,0,1)
		mata: temp = x,n
		mata: temp = sort(temp,1)
		mata: samp = temp[1::`G1',2]
		*mata: ptreat[.,`i']=samp
		mata: ptreat[.,`i']=`i'
		
	}
	
end /*end of PTREAT program */
/*--------------------------------------*/


/*WBRI program*/
/*---------------------------------------------*/
capture program drop MWWBRI
program define MWWBRI, rclass

	local y "`1'"
	 
	local x "`2'"
	 
	local c "`3'" 

	local cls "`4'"
	 
	local bcls "`5'"
		
	local B = "`6'"
	
	local w = `7'
	
	local null = "`8'"
	
	local  G1 = `9'
	
	local YS = `10'
	
	local YF = `11'
	
	local rcls "`12'"
	
		
	
	/*this is to put in a varlist of controls*/
		local ctrl "${`c'} "
		
	/*call the CHOOSER program*/
	CHOOSER `rcls' `G1' `B' 
	local permute = `r(permute)'
	local G = `r(G)'
	local R = `r(r)'
	
	/*call the PTREAT program, if needed*/
	
		PTREAT `G' `G1' `B'
	
		mata ptreat
	

	/*estimate t-hat */
	qui reg `y' `x' `ctrl' [w=asecwt], cluster(`cls')
	global bhat = _b[`x']
	local t_hat =  _b[`x']/ _se[`x']
	local beta =  _b[`x']
	mata: T_hat =`t_hat'
	mata: B_hat =`beta'
	
	qui predict temp_er, resid 
	qui predict temp_xbr, xb 
	
	
	disp "bootstrap DGP by " "`bcls'"
	
	/*set up bootstrap stuff*/
		
		cap drop temp_er temp_xbr temp_uni temp_ernew temp_pos temp_ywild
		
		/*if null imposed*/
		if ("`null'" == "R") {
		
			qui xi: reg `y' `ctrl'
					
			qui predict temp_er2, resid 
			qui predict temp_xbr2, xb
			
			qui replace temp_er = temp_er2
			qui replace temp_xbr = temp_xbr2
			}
		
		qui gen temp_uni = . 
		qui gen temp_ernew = . 
		qui gen temp_pos = . 
		qui gen temp_ywild = .
				
	/* matrix to store bootstrap statistics */
		mata: T_mw = J(`B'+1,`G',.)
		mata: B_mw = J(`B'+1,`G',.)
		
			*mata: T_mw
			*mata: B_mw
		
		/*create ID variable if needed*/
		if ("`bcls'" == "WILD") {
			local bcls = "TEMP_ID"
			qui gen TEMP_ID = _n
		}
		 
	
	/*RI loop*/
		forvalues r = 1/`G' { 
		
			disp "r = " `r'
			
				mata: ptreated = sort(ptreat[.,`b'],1)

				qui cap drop ptreat 
				qui gen ptreat = 0 
				
				/*assign fake treatment*/
				mata: st_numscalar("pg1", ptreated[1, `r'])
				mata: st_local("pg1", strofreal(ptreated[1,`r']))
						

				qui replace ptreat = 1 if temp_g==`pg1' & inrange(year,`YS',`YF')
			
			/*estimate the t-stat for the  randomized sample*/
				qui  reg  `y' ptreat `ctrl', cluster(`cls')
				
				/*store the t-stat*/
				if ("`null'" == "R") {
					local t_star =  _b[ptreat]/ _se[ptreat]
				}
				if ("`null'" == "U") {
					local t_star = (_b[ptreat]-${bhat})/(_se[ptreat])
				}
				
				local b_star = _b[ptreat]
				
				mata: T_mw [1,`r']=`t_star'
				mata: B_mw [1,`r']=`b_star'
				

	/*bootstrap loop*/
	
		forvalues b = 1/`B' {
		
		if ( mod(`b',100) == 0) {
			disp "r is " `r' " b count " `b'
			}
		
						
			sort `bcls'
			qui by `bcls': replace temp_uni = uniform()	
			
			if (`w' == 2) {				
				qui by `bcls': replace temp_pos = temp_uni[1]<.5   /*cluster level rademacher indicator*/
				qui replace temp_ernew = (2*temp_pos-1)*temp_er  /*transformed residuals */
				qui replace temp_ywild = temp_xbr + temp_ernew 
			}
			else if (`w' == 6) {
				#delimit ;
				qui by `bcls': replace temp_ernew = inrange(temp_uni[1],0,1/6)*temp_er*sqrt(1.5) + inrange(temp_uni[1],1/6,2/6)*temp_er *sqrt(1)+ 
					inrange(temp_uni[1],2/6,3/6)*temp_er*sqrt(0.5) + inrange(temp_uni[1],3/6,4/6)*temp_er*-sqrt(1.5)+
					inrange(temp_uni[1],4/6,5/6)*temp_er*-sqrt(1) + inrange(temp_uni[1],5/6,6/6)*temp_er*-sqrt(0.5);
				# delimit cr
			}
			qui replace temp_ywild = temp_xbr + temp_ernew 
			
			/*randomize*/
			 *qui replace ptreat = 1 if temp_g==`pg1' & inrange(year,`YS',`YF')
			
			/*estimate the t-stat for the bootstrap - randomized sample*/
				qui  reg temp_ywild ptreat `ctrl', cluster(`cls')

			/*store the t-stat*/
				if ("`null'" == "R") {
					local t_star =  _b[ptreat]/ _se[ptreat]
				}
				if ("`null'" == "U") {
					local t_star = (_b[ptreat]-${bhat})/(_se[ptreat])
				}
				
				local b_star = _b[ptreat]
				
				mata: T_mw [`b'+1,`r']=`t_star'
				mata: B_mw [`b'+1,`r']=`b_star'
				
		} /*end of bootstrap loop*/
				
	} /*end of r loop*/
	
		qui cap drop temp_er* temp_xbr* temp_uni temp_ernew temp_pos temp_ywild 
		qui cap drop TEMP_ID
		
		/*calculate the p-values*/
		mata: temp_rej =  abs(T_hat[1,1]):<=abs(T_mw)
		
		
		mata: temp_sum = sum(temp_rej) 
		mata: temp_den = rows(T_mw) * cols(T_mw)
		mata: mw_pt = temp_sum / temp_den
		mata: st_numscalar("mw_pt", mw_pt)
		mata: st_local("mw_pt", strofreal(mw_pt))
		return scalar wbript = `mw_pt'
		
		mata: temp_rej =  abs(B_hat[1,1]):<=abs(B_mw)
		mata: temp_sum = sum(temp_rej)
		mata: temp_den = rows(B_mw) * cols(B_mw)
		mata: mw_pb = temp_sum / temp_den
		mata: st_numscalar("mw_pb", mw_pb)
		mata: st_local("mw_pb", strofreal(mw_pb))
		return scalar wbripb = `mw_pb'
		
end
/*---------------------------------------------*/
