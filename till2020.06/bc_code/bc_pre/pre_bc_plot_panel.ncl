;;;????????????????
;;;???????????????????????
;3.16??????regcm????? 3x2
;3.19????????pre??????????????
;    ????BC?????????/??????
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;>>>read CN05.1&WRF cor data   
;####################################??????????????????##################################
  ; f_tm_bc_cclm = addfile("./practice/bc_data/temporary_data/bc_tm/bc_tm_cclm"+".nc", "r")
  f_pre_bc_wrf  = addfile("./practice/bc_data/temporary_data/bc_pre/bc_tm_wrf"+".nc", "r")
  f_pre_bc_cclm  = addfile("./practice/bc_data/temporary_data/bc_pre/bc_tm_cclm"+".nc", "r")
  f_pre_bc_regcm  = addfile("./practice/bc_data/temporary_data/bc_pre/bc_tm_regcm"+".nc", "r")
  ; f_tm_bc_regcm = addfile("./practice/bc_data/temporary_data/bc_tm/bc_tm_regcm"+".nc", "r")
;########################################################################################
  cor_wrf =   f_pre_bc_wrf->$"cor_tm_bc"$      ; ??????
  minus_ave_abs_wrf = f_pre_bc_wrf->$"minus_ave_abs"$ ; ???????
  minus_ave_rel_wrf = f_pre_bc_wrf->$"minus_ave_rel"$ ; ??????

  cor_cclm =   f_pre_bc_cclm->$"cor_tm_bc"$      ; ??????
  minus_ave_abs_cclm = f_pre_bc_cclm->$"minus_ave_abs"$ ; ???????
  minus_ave_rel_cclm = f_pre_bc_cclm->$"minus_ave_rel"$ ; ??????

  cor_regcm =   f_pre_bc_regcm->$"cor_tm_bc"$      ; ??????
  minus_ave_abs_regcm = f_pre_bc_regcm->$"minus_ave_abs"$ ; ???????
  minus_ave_rel_regcm = f_pre_bc_regcm->$"minus_ave_rel"$ ; ??????
  siglvl = 0.95
;>>>????????????????/???
  plot = new(6,graphic) ;???????????
  wks = gsn_open_wks("png","./practice/bc_data/temporary_data/pre_bc_minus_panel")
  ; gsn_define_colormap(wks,"MPL_Oranges")
    res = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet?? ????plot = ?????draw????????????????????????
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn             = True
  res@cnLinesOn            = False ;??????? 
  ; res@pmTickMarkDisplayMode = "Always"
  ; res@lbLabelBarOn        = False            ; turn off individual cb's
;-------------------------------------------------------???????????????????????res@mp
    res@mpMinLatF=14
    res@mpMaxLatF=55
    res@mpMinLonF=69
    res@mpMaxLonF=140
    res@mpDataBaseVersion = "Ncarg4_1"   ;???????????????
    res@mpDataSetName="Earth..4"

    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China","Taiwan"/)
    res@mpFillOn=False
    res@gsnAddCyclic=False

    res@mpGridAndLimbOn=True             ;?????????
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10

;-------------------------------------------------------???????????
  ;;;
                
  res@gsnCenterString = "Deviation between BC of WRF & CN05.1 dataset"
  ; res@tiMainString    = "MEAN TEMPERATURE AT 2M HEIGHT"
  res@gsnCenterStringFontHeightF = 0.02  
  res@pmTickMarkDisplayMode = "Always" ;???????????? ?? ????(????????)
  res@gsnLeftString = "" ;???????????
  res@gsnRightString= "" ;???????????

;-------------------------------------------------------????/x/y/???????  

  ;;;>>>??????????
  res@cnFillPalette         = "MPL_Oranges"; ??GMT_gray ??????????????????2?????(?????????)
  res@tmYLTickStartF = 0  ; ???????????
  res@tmYLTickEndF   = 60 ;??????
  res@tmYLTickSpacingF = 10 ;?????
  res@tmXBTickSpacingF = 15 

  res@lbOrientation = "Vertical" ; ???????????? 
  ; res@gsnContourZeroLineThicknessF = 0. ;???0??
 
  res@cnLevelSelectionMode = "ManualLevels" ;?????????????????
  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 10
  res@cnLevelSpacingF = 2.0 ;???????

;;;;----------------------------------------------------resc ????
   resc = res
  resc@gsnCenterString = "Relative error between BC of WRF & CN05.1 dataset"
  resc@cnFillPalette         = "GMT_polar"; ??GMT_gray ??????????????????2?????(?????????)
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  resc@cnLevelSelectionMode = "ManualLevels"
  ; resc@cnLevelSelectionMode = "AutomaticLevels" 
  resc@cnMinLevelValF = 0
  resc@cnMaxLevelValF = 5
  resc@cnLevelSpacingF = 0.5 ;??????? 
  ; resc@cnLevels              = (/-0.2,-0.1, 0, 0.1, 0.2, 0.3, 0.4/)  
  resc@cnFillColors          = (/-1,-1,9,8,6,4,12,13,14,15,16,17,18,19/); -1 ????


  ; resc@cnInfoLabelOn         = True       ; ???????? ??????????????
  ; resc@lbLabelBarOn          = True       ; ???labelbar
;;;;---------------------------------------------
  plot(0) = gsn_csm_contour_map(wks, minus_ave_abs_wrf, res)
  ; gsn_define_colormap(wks,"MPL_Oranges")
  plot(3) = gsn_csm_contour_map(wks, minus_ave_rel_wrf, resc)
  ; plot(2) = gsn_csm_contour_map(wks, cv_mod, resc)
  res@gsnCenterString = "Absolute error between BC of CCLM & CN05.1 dataset"
  resc@gsnCenterString = "Relative error between BC of CCLM & CN05.1 dataset"
  plot(1) = gsn_csm_contour_map(wks, minus_ave_abs_cclm, res)
  plot(4) = gsn_csm_contour_map(wks, minus_ave_rel_cclm, resc)
  ;;;;----------------------------------------------RegCM????
  res@gsnCenterString = "Absolute error between BC of RegCM & CN05.1 dataset"
  resc@gsnCenterString = "Relative error between BC of RegCM & CN05.1 dataset"
  plot(2) = gsn_csm_contour_map(wks, minus_ave_abs_regcm, res)
  plot(5) = gsn_csm_contour_map(wks, minus_ave_rel_regcm, resc)
;;;;----------------------------------------------panel seeting
  pres = True
  pres@txString              = "MEAN DAILY PRECEPTION"
  ; pres@gsnPanelLabelBar      = True ; ??????????
  pres@gsnPanelFigureStrings = (/"A","B","C","D","E","F"/)
  pres@amJust                = "TopLeft" ;??????????

  gsn_panel(wks,plot,(/2,3/),pres)

;;;;---------------------------------------------
  ; draw(plot)
  ; frame(wks)
  ; draw(plot)
  ; frame(wks)
  
end