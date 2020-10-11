;       10.05   捆绑CPC和CCLM的绘图res，绘制一张panel方便对比
;               绘制前一步sum的运行结果
;               属性设置较为混乱，因为是直接拼凑而成
;               来自 prec_cclm_output 和 prec_CMORPH_plot_single 两个NCL脚本
begin

;;;>>>>> read data
    start_day  = 19
    end_day    = 24
    file_path = "/m2data2/yycheng/data_stage/cptp/postprocess_data/prec_check_temporary/"
    file_name = "prec_sum_07"+start_day+"_07"+end_day+".nc"
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


;;;>>>>>error data combine
    ; printVarSummary(prec_obs_sum)
    ; prec_cclm_sum = where(prec_cclm_sum.gt.400., 400, prec_cclm_sum)
    ; prec_obs_sum = where(prec_obs_sum.gt.350., 350, prec_obs_sum)
    ; printVarSummary(prec_obs_sum)
        

wks  = gsn_open_wks("png", "./output_pic/totprec_from_nc")     ; send graphics to PNG file
    plot = new ( 2 , "graphic")
    res                        = True             ; plot mods desired
    res@lbLabelBarOn           = False            ; turn off individual cb's
    res@gsnMaximize            = True             ; maxmize plot in frame

    res@cnFillOn               = True             ; turn on color 
    res@cnLinesOn              = False            ; no contour lines
    res@cnLineLabelsOn         = False            ; no contour labels
    res@mpDataBaseVersion      = "MediumRes"      ; use finer database
    res@mpOutlineBoundarySets  = "National"

    ;---Turn on nicer tickmarks. 'conditional' prevents more than one tickmark object.
    res@pmTickMarkDisplayMode  = "conditional"

    res@gsnAddCyclic           = False
    res@gsnRightString         = ""

    ; res@cnFillPalette          = "perc2_9lev"
    ; res@cnMinLevelValF = 0
    ; res@cnMaxLevelValF = 360
    ; res@cnLevelSpacingF = 20 ;等值线间隔

      res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/10,20,30,40,50,100,150,200,250,300/) ; "mm/day" 
       res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                                   ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels


    ;;;>>>-----native plotting-----
    res_native = res

    ;---Zoom in on map

    ; Setting tfDoNDCOverlay to True ("NDCViewport") means you have specified
    ; the exact projection that your data is on, and thus no data
    ; transformation takes place when the contours are overlaid
    ; on the map.   

    res_native@tfDoNDCOverlay        = True
    ; res_native@tfDoNDCOverlay        = "NDCViewport"  ; NCL V6.5.0 or later
    res_native@lbLabelBarOn        = False            ; turn off individual cb's
    res_native@mpLimitMode            = "Corners"
    res_native@mpLeftCornerLatF       = lat2d_cclm(0,0)   
    res_native@mpLeftCornerLonF       = lon2d_cclm(0,0) 
    res_native@mpRightCornerLatF      = lat2d_cclm(nlat_cclm-1,nlon_cclm-1)    
    res_native@mpRightCornerLonF      = lon2d_cclm(nlat_cclm-1,nlon_cclm-1)

    res_native@tiMainString           = "CCLM OUTPUT"
    res_native@pmTickMarkDisplayMode  = "always"

    res_native@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
    res_native@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

    ; res@tiMainString           = "Native rotated lat/lon Projection"

    res@mpMinLatF            = -60.     ; CMORPH limits [approx]
    res@mpMaxLatF            =  60.
    res@mpCenterLonF         = 210.
    res@mpFillOn             = False

    ; res@mpShapeMode          = "FreeAspect"
    ; res@vpWidthF             = 0.8
    ; res@vpHeightF            = 0.4

    ; limit area
    res@mpLimitMode            = "Corners"
    res@mpLeftCornerLatF       = 15.99613   
    res@mpLeftCornerLonF       = 66.63403
    res@mpRightCornerLatF      = 44.66093
    res@mpRightCornerLonF      = 118.7213

    ; res@tiMainString           = "Native projection"
    res@pmTickMarkDisplayMode  = "always"

    pole_lat = 57.
    pole_lon = -91.5
    res@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
    res@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

    res@tiMainString           = "CMORPH 0.25degree"

    plot(0) = gsn_csm_contour_map(wks,prec_obs_sum(:,:),res)    ; Draw plot
    plot(1) = gsn_csm_contour_map(wks,prec_cclm_sum(:,:),res_native)

resP = True
    resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
    ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@lbLabelFontHeightF  = 0.0175              ; change font size
    ; resP@gsnPanelLabelBar    = True ; 公用一个色标
    ; resP@lbOrientation       = "vertical"    
    ;    resP@gsnPanelMainString  = "CMORPH: "+fili
    gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot


end