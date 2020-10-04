  ; 4.2 进行不同气候带位置的绘制
  ; load "./offical_sample_script/download/taylor_diagram.ncl"

  ; ---main code---
begin

parts = (/"H 高原气候区","I 北温带","II 中温带","III 南温带","IV 北亚热带",\
         "IX 南热带","V 中亚热带",\
         "VI 南亚热带","VII 北亚热带","VIII 中热带"/)
 
type = "tm"
  ; windows_path = "/mnt/D/DATAFILE/NCLDATA/bc_data/RegCM_PRE_daily_025x025.nc"

  path_part = "/mnt/D/DATAFILE/NCLDATA/bc_data/temporary_data/bc_"+type+"/parts/mask"+".nc"
  ncdf_step1 = addfile(path_part, "r") ; c表示创建netcdf文件
  mask_check = ncdf_step1->$"mask_check"$ ;写入变量数值
  delete(ncdf_step1)
;>>>------plot test
print("--ready to plot--")
wks = gsn_open_wks("png","~/practice/bc_code/damp")
gsn_define_colormap(wks,"rainbow")
  res                 = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用        
  res@gsnAddCyclic = False
  res@gsnLeftString   = "type"                  
  res@gsnRightString  = ""                 
  res@gsnCenterString = "Climate_quhua"
  res@gsnCenterStringFontHeightF = 0.02  
  
  res@pmTickMarkDisplayMode = "Always"
  
  ;; 绘制的地图区域
  res@mpMinLatF                  = 15.                         
  res@mpMaxLatF                  = 55.
  res@mpMinLonF                  = 72.
  res@mpMaxLonF                  = 136.
   
  
  res@mpFillOn               = False
  res@mpGridAndLimbOn        = True
  res@mpGridLineThicknessF   = 0.5
  res@mpGridLineDashPattern  = 2 ;grid线型         
  res@mpGridSpacingF         = 10.     ;
  res@mpCountyLineThicknessF = 10.
  res@mpProvincialLineThicknessF = 7.
   res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    ; res@mpDataSetName="Earth..4"
     res@mpDataSetName = "~/NCL-Chinamap-master/database/Earth..4" ; 使用大气所的dataset数据
    ;  res@mpDataSetName = "Earth..4"
    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China:Provinces"/)
    res@mpFillOn=False
    res@gsnAddCyclic=False

  res@cnFillOn      = True                  
  res@cnLinesOn     = True

  ; res@pmTickMarkDisplayMode = "Always"
plot = gsn_csm_contour_map(wks, mask_check, res)
; add_labelbar(wks,plot,parts,rgba,1.0)    ; Attach a custom labelbar to the plot
draw(plot)
frame(wks)

end