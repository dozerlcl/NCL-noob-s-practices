;画cnmap地形图
;参考气象家园中“正确绘制中国地图”帖文
;http://bbs.06climate.com/forum.php?mod=viewthread&tid=45252
begin
;D:\DATAFILE\NCLDATA\data
  f=addfile("./practice/lx2_data/hgt.sfc.nc","r")
  var = short2flt( f->hgt(0,:,:))
  
  wks = gsn_open_wks("x11","contourmap")     
  gsn_define_colormap(wks,"GMT_gray")
   
  res                 = True  
  res@gsnFrame    = False
  res@gsnDraw     = False     ; don't draw plot yet， 避免plot = 之后再draw，画两张图；有叠加的时候使用        
  res@gsnLeftString   = "height"                  
  res@gsnRightString  = "m"                 
  res@gsnCenterString = "Terrian over part China Map with SCS"
  res@gsnCenterStringFontHeightF = 0.02  
  
  res@pmTickMarkDisplayMode = "Always"
  
  ;; 绘制的地图区域
  res@mpMinLatF                  = 0.                         
  res@mpMaxLatF                  = 55.
  res@mpMinLonF                  = 72.
  res@mpMaxLonF                  = 136.
   
  
  res@mpFillOn               = False
  res@mpGridAndLimbOn        = True
  res@mpGridLineThicknessF   = 0.5
  res@mpGridLineDashPattern  = 2 ;grid线型         
  res@mpGridSpacingF         = 10.     ;

  res@cnFillOn      = True                  
  res@cnLinesOn     = True   

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(1500,4500,1000);(/1500,2500,3500,4500/)
  ;等差数列，也可以用"cnlevelselectionmode" = "mannuallevels"的形式，如同lx1_contour里面的处理
  res@cnFillColors         = (/-1,10,8,6,4/)
  ; 下面是拼接的脚本     
  ; 正确中国地图的绘制 Thank Dr. Yongjie Huang (IAP/CAS) for providing map database 
  res@mpDataSetName              = "./NCL-Chinamap-master/database/Earth..4"
  res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
  res@mpAreaMaskingOn            = True
  res@mpMaskAreaSpecifiers       = (/"China"/)
  res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)     

  res@mpLandFillColor            = "white"
  res@mpInlandWaterFillColor     = "white"
  res@mpOceanFillColor           = "white"
  res@mpFillBoundarySets         = "NoBoundaries"
  res@mpOutlineBoundarySets      = "NoBoundaries"
  res@mpNationalLineColor        = "black"
  res@mpProvincialLineColor      = "black"
  res@mpGeophysicalLineColor     = "black"
  res@mpNationalLineThicknessF   = 2
  res@mpProvincialLineThicknessF = 1    
;---------------------------------------------------------------
; plot one part of China map with South China Sea subplot
  res@mpMinLatF                  = 5.
  ; res@gsnLeftString              = "Surface pressure over part China Map with SCS"
  ; 先绘制变量var的map1
  map1 = gsn_csm_contour_map(wks, var, res) ;输出第一次map1，保存在001.里面,此前设置了res@gsdraw就不绘制

;--- add South China Sea --- 
  nhres                          = True
  nhres@gsnFrame                 = False
  nhres@gsnDraw                  = False
      
  nhres@vpHeightF                = 0.18    
  nhres@vpWidthF                 = 0.18
    
  nhres@mpMinLatF                =   2.0    
  nhres@mpMaxLatF                =  23.0
  nhres@mpMinLonF                = 105.0
  nhres@mpMaxLonF                = 123.0
  ;将map1中的res的设置转存到nhres中
  getvalues map1
    "mpDataSetName"              : nhres@mpDataSetName
    "mpDataBaseVersion"          : nhres@mpDataBaseVersion
    "mpFillOn"                   : nhres@mpFillOn
    "mpFillDrawOrder"            : nhres@mpFillDrawOrder
    "mpAreaMaskingOn"            : nhres@mpAreaMaskingOn
    "mpMaskAreaSpecifiers"       : nhres@mpMaskAreaSpecifiers 
    "mpOutlineSpecifiers"        : nhres@mpOutlineSpecifiers
    "mpOutlineBoundarySets"      : nhres@mpOutlineBoundarySets
    "mpLandFillColor"            : nhres@mpLandFillColor       
    "mpOceanFillColor"           : nhres@mpOceanFillColor      
    "mpInlandWaterFillColor"     : nhres@mpInlandWaterFillColor
    "mpNationalLineColor"        : nhres@mpNationalLineColor   
    "mpProvincialLineColor"      : nhres@mpProvincialLineColor 
  end getvalues

  getvalues map1@contour
    "cnFillOn"                   : nhres@cnFillOn
    "cnLevelSelectionMode"       : nhres@cnLevelSelectionMode
    "cnLevels"                   : nhres@cnLevels
    "cnFillColors"               : nhres@cnFillColors
    "cnFillDrawOrder"            : nhres@cnFillDrawOrder
    "cnLinesOn"                  : nhres@cnLinesOn
    "cnLineLabelsOn"             : nhres@cnLineLabelsOn
  end getvalues

  nhres@lbLabelBarOn             = False
  nhres@tmXBOn                   = False 
  nhres@tmYLOn                   = False
  nhres@tmYROn                   = False
  nhres@tmXTOn                   = False
  nhres@gsnLeftString            = ""
  nhres@gsnRightString           = ""

  map_nanhai = gsn_csm_contour_map(wks,var,nhres); 在map_nanhai中绘制var
  ;adres描述在map1中添加map_nanhai
  adres                          = True
  adres@amParallelPosF           = 0.495 ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF         = 0.49  ; -0.5 is the top edge of the plot.
  adres@amJust                   = "BottomRight"

  plotnh = gsn_add_annotation(map1,map_nanhai,adres)
  ;最后一次性画出
  draw(map1)
  frame(wks)


end
