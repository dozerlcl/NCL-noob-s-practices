;   10.04   绘制一张CPC进行sum之后的结果，用于检验

begin

;;;>>>>> read data
    file_path = "/m2data2/yycheng/data_stage/cptp/postprocess_data/prec_check_temporary/"
    file_name = "prec_sum_0718_0723"+".nc"
    f_or = addfile(file_path + file_name, "r")
    prec_obs_sum  = f_or->$"sum_obs"$
    prec_cclm_sum = f_or->$"sum_cclm"$
    
    ;;; cclm相对麻烦的坐标
    rotated_pole = f_or->$"rotated_pole"$
    pole_lon = rotated_pole@grid_north_pole_longitude
    pole_lat = rotated_pole@grid_north_pole_latitude
    rlat_cclm   = f_or->$"rlat"$
    rlon_cclm   = f_or->$"rlon"$
    lat2d_cclm  = f_or->$"lat2d"$
    lon2d_cclm  = f_or->$"lon2d"$
    nlat_cclm   = dimsizes(lat2d_cclm(:,0))
    nlon_cclm   = dimsizes(lon2d_cclm(0,:))


wks    = gsn_open_wks("png", "./output_pic/cpcsum_check_nc")
   
       plot = new ( 1 , "graphic")
     
       res                      = True         ; plot mods desired
       res@gsnDraw              = False        ; don't draw
       res@gsnFrame             = False        ; don't advance frame
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines

       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpMinLatF            = -60.     ; CMORPH limits [approx]
       res@mpMaxLatF            =  60.
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
   
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4

        ; limit area
        res@mpLimitMode            = "Corners"
        res@mpLeftCornerLatF       = 15.99613   
        res@mpLeftCornerLonF       = 66.63403
        res@mpRightCornerLatF      = 44.66093
        res@mpRightCornerLonF      = 118.7213

        res@tiMainString           = "Native projection"
        res@pmTickMarkDisplayMode  = "always"

        pole_lat = 57.
        pole_lon = -91.5
        res@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
        res@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

        res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/10,20,30,40,50,100,150,200,250,300/) ; "mm/day" 
       res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                                   ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels

        ; res@tiMainString           = "Native rotated lat/lon Projection"
        ; res@cnFillPalette          = "perc2_9lev"
        ; res@cnMinLevelValF = 0
        ; res@cnMaxLevelValF = 360
        ; res@cnLevelSpacingF = 20 ;等值线间隔
        ;



   
    ;    res@gsnCenterString = "Areal Mean="+sprintf("%4.2f", prec_obs_sum)
    ;    plot(0) = gsn_csm_contour_map(wks,comb, res)
   
    ;    res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  prec_obs_sum)
        ; printVarSummary(data)
       plot(0) = gsn_csm_contour_map(wks,prec_obs_sum, res)
   
      ;delete(work)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
    ;    resP@gsnPanelMainString  = "CMORPH: "+fili
       gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot





end