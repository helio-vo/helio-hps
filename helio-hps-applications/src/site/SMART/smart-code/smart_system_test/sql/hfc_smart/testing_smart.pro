pro testing_smart,file=file,lines=lines

if ~keyword_set(file) then read,prompt=' where is the file you want to test? ',file
if ~keyword_set(lines) then read, prompt=' which lines you want to test? ',lines
readcol,file,id,frc_id,ob_id,ob_id_t,r_date,ar_date,ar_date_t,sc_arcx,sc_arcy,sc_carlat, $
        sc_carlon,npix,area,brarcx1,brarcy1,brarcx2,brarcy2,brpxx1,brpxy1,brpxx2, $
        brpxy2,max_int,min_int,mean_int,lnl,lsg,grad_max,grad_mean,grad_median,rval,$
        wlsg,met,cc_pix_x,cc_pix_y,cc_arc_x,cc_arc_y,cc,ccl

end
