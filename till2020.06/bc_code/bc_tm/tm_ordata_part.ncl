;  3.31 尝试拆分各个流域 
;    读入原始数据 ordata 的经纬度数据作为需要拆分的母版
;    将拆分结果保存到mask_check 中， 区域上的值 与 names_list 相应位置的区域名相对应
;    使用例: 若需对ordata进行拆分
;    用ordata生成拆分模板mask_check[lat x lon]
;    ordata = where(mask_check.eq.[所需区域序号], ordata, ordata@_Fillvalue)
;    即可将拆分结果应用到mod1_or其他维度上 需使用函数conform 示范参考heat_plot_preprocess.ncl
;  参考示例：https://www.ncl.ucar.edu/Applications/shapefiles.shtml
;  load函数需要：
;    http://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl
load "./offical_sample_script/Scripts/shapefile_utils.ncl"
begin
;>>>------整理原始数据（随便读入个变量
    f_cat_1 = addfile("./practice/bc_data/temporary_data/bc_PRE/ncl_to_r/tm_cat_CN051_WRF_step2.nc","r")
  ; ; ;>>>>05.1观测数据集,平均气温
    ; obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    mod1_or = f_cat_1->$"tm_wrf_step2"$
;>>>------shpfile read
;  shp文件只有一个 但是同一目录下均是shp的关联文件如.shx .dbf
  shpfile   ="./NCL-Chinamap-master/quhua/Climate_quhua.shp"
  f_shp = addfile(shpfile, "r")
  print_shapefile_info(shpfile) ; 查看信息
  names = f_shp->$"Qu1"$ ; 
  ; plot_shapefile初步绘制分区:需自己调整shapefile_utils.ncl文件中的绘制函数
  ; plot_shapefile(shpfile)
  names_list = get_unique_values(names) ; 将独特的names整理出来，方便后续循环
  print(names_list)
;   ; 示例shp文件 Qu1逐个区域：
; (0)    [注意是空！不是没有！]
; (1)     H 高原气候区
; (2)     I 北温带
; (3)     II 中温带
; (4)     III 南温带
; (5)     IV 北亚热带
; (6)     IX 南热带
; (7)     V 中亚热带
; (8)     VI 南亚热带
; (9)     VII 北亚热带
; (10)    VIII 中热带
;>>>------mask
  mask_check = mod1_or(0,:,:)
  mask_check = 0 ; 懒得写坐标复制，直接赋值好了 结果保存到和mod1_or(0,:,:)相同的mask_check中
  dim_names = dimsizes(names_list)
  opt             = True
  opt@return_mask = True ; 将所在区域返回1
  opt@shape_var   = "Qu1";先设置全部区域的名字（var在其中搜索！非常重要！本体的函数说明写的很糊弄
  do i = 1, dim_names - 1 ; 只有1-10有值
  opt@shape_names = names_list(i) ;"I 北温带";"II 中温带"
  land_mask  = shapefile_mask_data(mod1_or(0,:,:),shpfile,opt)
  mask_check = where(land_mask.eq.1, i, mask_check) ; 需要位置设置为i mask掉设置为0
  delete(land_mask)
  end do
  mask_check@areas_names = names_list ; 名字保存为mask结果的属性
;>>>------output
  type = "tm"
  path_out = "./practice/bc_data/temporary_data/bc_"+type+"/parts/mask"+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf_step1 = addfile(path_out, "c") ; c表示创建netcdf文件
  ncdf_step1->mask_check  = mask_check ;写入变量数值
  delete(ncdf_step1)
;>>>------plot test 检查mask效果
print("--ready to plot--")
wks = gsn_open_wks("x11","./practice/bc_data/temporary_data/part_test")
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
  res@mpMinLatF                  = 14.                         
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
  ; res@pmTickMarkDisplayMode = "Always"
plot = gsn_csm_contour_map(wks, mask_check, res)
draw(plot)
frame(wks)

end