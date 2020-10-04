  ; 2020.09.05
  ; 进行out01输出文件的测试
  ; 由于使用rotated coordinates 参考NCL官网示例脚本 
  ; https://www.ncl.ucar.edu/Applications/rotatedltln.shtml
  ; COSMO模型使用例
  ; http://www.ncl.ucar.edu/Applications/cosmo.shtml
  ; 另外有两个NCL-TALK查到的部分可以做参考（核心的东西是一致的）
  ; https://www.ncl.ucar.edu/Support/talk_archives/2009/0052.html
  ; https://www.ncl.ucar.edu/Support/talk_archives/2008/0970.html

  ; 关于transform资源的使用（关系到是不是native的网格）可以参考NCL官网给出的资源的使用例
  ; https://www.ncl.ucar.edu/Document/Graphics/Resources/tf.shtml


  ; remark: 使用 lon2d lat2d 这样的经纬度坐标稍微好办事一点

  ; 09.01
  ; CP并修改为进行cptp的区域外部数据EXPAR的检查

;;;添加一个常见的批量输出文件f中所有数据信息的方法，类似于ncdump -h 
undef("pvs")
procedure pvs(x)
local i,varnames
begin
    printVarSummary(x)

    if (isfile(x))then
        varnames = getfilevarnames(x)
        if(.not.any(ismissing(varnames))) then
            do i=0,dimsizes(varnames)-1
                printFileVarSummary (x,varnames(i))
            end do
        end if
    end if

end

begin

;;;>>>>>data reader
  file_path = "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/"
    file_name = "cptp_test3_0911.nc"
  f_ordata = addfile(file_path + file_name, "r")
  ; printVarSummary(f_ordata)
  ; pvs(f_ordata)
  t_ordata = f_ordata->$"ALB_DRY"$
  rlat = f_ordata->$"rlat"$
  rlon = f_ordata->$"rlon"$
  ;;; rotatead pole就存储在rotated_pole之中
  rotated_pole = f_ordata->$"rotated_pole"$
  pole = f_ordata->rotated_pole
  pole_lon = pole@grid_north_pole_longitude
  pole_lat = pole@grid_north_pole_latitude
  lat2d  = f_ordata->$"lat"$
  lon2d  = f_ordata->$"lon"$
  nlat  = dimsizes(lat2d(:,0))
  nlon  = dimsizes(lon2d(0,:))
  ;;;>>>data checker
  
;;;>>>>>start plot
    ;---Start the graphics section
  wks  = gsn_open_wks("png", "./output_pic_out1/rotatedltln_01")     ; send graphics to PNG file

  res                        = True             ; plot mods desired

  res@gsnMaximize            = True             ; maxmize plot in frame

  res@cnFillOn               = True             ; turn on color 
  res@cnLinesOn              = False            ; no contour lines
  res@cnLineLabelsOn         = False            ; no contour labels
  res@cnFillPalette          = "BlGrYeOrReVi200"

  res@mpDataBaseVersion      = "MediumRes"      ; use finer database
  res@mpOutlineBoundarySets  = "National"

;---Turn on nicer tickmarks. 'conditional' prevents more than one tickmark object.
  res@pmTickMarkDisplayMode  = "conditional"

  res@gsnAddCyclic           = False
  res@gsnRightString         = ""

;;;关键的参数设置 tfDoNCDOverlay(具体参考官网使用例) ，如果写入
;;;True  -> plotting the data natively
;;;False -> transform
;;;示例:
; res@tfDoNDCOverlay        = True
; res@tfDoNDCOverlay        = "NDCViewport"  ; NCL V6.5.0 or later
; res@tfDoNDCOverlay        = False      ; transform to standard lat/lon
; res@tfDoNDCOverlay        = "DataTransform"  

;;;>>>-----native plotting-----
  res_native = res

  ;---Zoom in on map

    ; Setting tfDoNDCOverlay to True ("NDCViewport") means you have specified
    ; the exact projection that your data is on, and thus no data
    ; transformation takes place when the contours are overlaid
    ; on the map.   

  res_native@tfDoNDCOverlay        = True
  ; res_native@tfDoNDCOverlay        = "NDCViewport"  ; NCL V6.5.0 or later

  res_native@mpLimitMode            = "Corners"
  res_native@mpLeftCornerLatF       = lat2d(0,0)   
  res_native@mpLeftCornerLonF       = lon2d(0,0) 
  res_native@mpRightCornerLatF      = lat2d(nlat-1,nlon-1)    
  res_native@mpRightCornerLonF      = lon2d(nlat-1,nlon-1)

  res_native@tiMainString           = "Native projection"
  res_native@pmTickMarkDisplayMode  = "always"

  res_native@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
  res_native@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

  res@tiMainString           = "Native rotated lat/lon Projection"

plot = gsn_csm_contour_map(wks,t_ordata(:,:),res_native)    ; Draw plot

;;;>>>-----no-native-----
  res_nonnative = res           ; Copy over common resources.

  res_nonnative@sfXArray                 = lon2d    ; needed for non-native
  res_nonnative@sfYArray                 = lat2d    ; contouring

  res_nonnative@mpMinLatF                = min(lat2d)
  res_nonnative@mpMinLonF                = min(lon2d)
  res_nonnative@mpMaxLatF                = max(lat2d)
  res_nonnative@mpMaxLonF                = max(lon2d)
  
  res_nonnative@pmLabelBarOrthogonalPosF = 0.05
  res_nonnative@tiMainString             = "Non-native projection"

plot = gsn_csm_contour_map(wks,t_ordata(:,:),res_nonnative)    ; Draw plot

end