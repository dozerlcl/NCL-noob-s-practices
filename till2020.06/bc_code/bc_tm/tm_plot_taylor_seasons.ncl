;  3.26 绘制 3个models四季的taylor diagrams
;    调节了路径名，用于处理了pre的数据
;**********************************
load "./offical_sample_script/download/taylor_diagram.ncl" ; 原始脚本 Xmax =  1.65 X超过范围慎用
; load "./taylor_diagram_enoble.ncl" ; 无法绘制vars
; load "./taylor_diagram_less_hardcoded.ncl" ; 一个自动校正X轴 适用于RSME较大的情况
; load "./taylor_stats.ncl" ； 统计函数的计算脚本
; load "./taylor_metrics_table.ncl"
load "./offical_sample_script/download/pvs.ncl"
;**********************************
begin

;>>>---------------------------------------------------整理tylor绘图数据
; 注意名称的对应
file_num = 3
type = "tm"
dir_sim = "./practice/bc_data/temporary_data/bc_"+type+"/taylor/"
nc_files = systemfunc("ls "+dir_sim+"taylor_seasons_*.nc"); 批量读入文件systemfunc('ls'+"文件名共同部分.*.nc")
f_1 = addfiles(nc_files,"r")
file_names = new(file_num, "string") ; 含路径的文件名字符串数组
bc_o = new((/4,file_num,8/), "float")  ; [季节:DJF...SON] x [模式] x [stats8统计量,ratio为1，cor为0]
mod_o = new((/4,file_num,8/), "float")
do i = 0, file_num-1 ; 模式名 0-CCLM 1-RegCM 2-WRF
  file_names(i) = getfilepath(f_1[i])
  bc_o(0, i, :) = f_1[i]->$"stats_bc_DJF"$
  bc_o(1, i, :) = f_1[i]->$"stats_bc_MAM"$
  bc_o(2, i, :) = f_1[i]->$"stats_bc_JJA"$
  bc_o(3, i, :) = f_1[i]->$"stats_bc_SON"$

  mod_o(0, i, :) = f_1[i]->$"stats_mod_DJF"$
  mod_o(1, i, :) = f_1[i]->$"stats_mod_MAM"$
  mod_o(2, i, :) = f_1[i]->$"stats_mod_JJA"$
  mod_o(3, i, :) = f_1[i]->$"stats_mod_SON"$
end do
  ;>>>--------------------------------------------------检查数据
; pvs(bc_o)
; print(bc_o(:,:,7))
; print(mod_o(:,:,7))
print(file_names)
; print(bc_o)
; pvs(f_1[0])
  print("---------------------ALL IS WELL---------------------")
  ;>>>----------------------------------------------------将数据排列进ratio cc
; ;A:mod_o B:bc_o
; ; Cases [Model]
  case      = (/"CCLM_MOD", "RegCM_MOD","WRF_MOD","CCLM_BC","RegCM_BC","WRF_BC"/) 
  nCase     = dimsizes(case)                 ; # of Cases [Cases]

; ; variables compared
  var       = (/ "DJF","MAM","JJA","SON"/) 
  nVar      = dimsizes(var)                   ; # of Variables

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(bc_o) )  
  cc         = new ((/nCase, nVar/),typeof(bc_o) ) 

  do i = 0, file_num - 1 ; i 循环model 
    do j = 0, nVar - 1 ; j 循环seasons DJF MAM JJA SON
      ratio(i,j) = mod_o(j,i,1) ; ratio 第i个mod 对应 mod_o 第i个mod
      cc(i,j) = mod_o(j,i,0)
      ratio(i+file_num,j) = bc_o(j,i,1)
      cc(i+file_num,j) = bc_o(j,i,0)
    end do
  end do
; print(cc)
print(ratio)
print("------------------ratio check--------------------")


; ;>>>---------------------------------------------------作图

;   ; varSource = var +"_"+ source              ; add extra info [*not* required]

  ty_opt   = True                           ; taylor diagram with options
        
  ty_opt@Markers       = (/14, 14, 14, 16, 16, 16/)         ; make all solid fill
  ty_opt@Colors        = (/"red","blue","green", "red", "blue","green"/)          
  ty_opt@varLabels     = var
  ty_opt@caseLabels    = case
  

  ty_opt@varLabelsYloc = 0.7                ; Move location of variable labels [default 0.45]
  ty_opt@caseLabelsFontHeightF = 0.14       ; make slight larger   [default=0.12 ]
  ty_opt@varLabelsFontHeightF  = 0.01      ; make slight smaller  [default=0.013]
  ty_opt@txFontHeightF = 0.013
  ty_opt@tiMainString  = "20000101-20011231-TM"           ; title
  ty_opt@stnRad        = (/ 0.5, 1.5 /)     ; additional standard radii
  ty_opt@ccRays        = (/ 0.6, 0.9, 0.99/)     ; correllation rays
  ty_opt@centerDiffRMS = True               ; RMS 'circles'
  ty_opt@drawCorLabel  = False
  wks   = gsn_open_wks("png","./practice/bc_data/temporary_data/taylor_tm_seasons_02")      ; send graphics to PNG file
  plot  = taylor_diagram(wks,ratio,cc,ty_opt)

; ; ;**************************************************
; ; ; fill an array for a "taylor metrics table"
; ; ;**************************************************

; ;   ; season    = (/ "ANN" /)
; ;   ; nSeason   = dimsizes(season)

; ;   ; table     = new ( (/nCase,nSeason,nVar/), typeof(ratio) )
; ;   ; table(0,0,:) = CA_ratio
; ;   ; table(1,0,:) = CB_ratio

; ;   ; tt_opt        = True
; ;   ; tt_opt@pltType= "x11"                  ; "eps" [default], "pdf", "ps"
; ;   ;                                        ; "png", "gif" [if you have ImageMajik 'convert']
; ;   ; tt_opt@color0 = "palegreen2"
; ;   ; tt_opt@color1 = "tomato2"


; ;   ; taylor_metrics_table("taylor.000002", varSource, case ,season, table, tt_opt)
end