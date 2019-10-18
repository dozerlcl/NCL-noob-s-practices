begin 
  nstat = 160 ; 160站
  year_s = 1951 
  year_e = 2011 
  nyear  = year_e - year_s + 1
  
  ; (1) 读入6/7/8三个月的降水
  path6 = "./practice/lx2_data/r1606.TXT"
  path7 = "./practice/lx2_data/r1607.TXT"  
  path8 = "./practice/lx2_data/r1608.TXT" 
  path_out_fb = "./practice/lx2_data/preci-" + nstat + "-JJA-30yr.grd"
  m6 = asciiread(path6, (/nyear, nstat/), "float")
  
  ; 设定meta data
  m6!0 = "year"
  m6!1 = "stations"
  m6&year = ispan(year_s, year_e, 1)
  m6&stations = ispan(1, nstat, 1)
  ;将元数据中的变量属性给赋值到m7,m8
  m7 = m6  ; 创建新的变量m7
  m8 = m6  ; 创建新的变量m8
  ; 读入7，8两个月的降水量
  m7 = asciiread(path7, (/nyear, nstat/), "float")
  m8 = asciiread(path8, (/nyear, nstat/), "float")
  ;(2) 仅计算1979年至2008年逐年的JJA平均
  mm = m6({1979:2008},:) ; 创建新的变量
  mm = m6({1979:2008},:) + m7({1979:2008},:) + m8({1979:2008},:)
  
  ;(3) 输出为无格式二进制文件
  fbindirwrite(path_out_fb, mm) ; 如果有同名文件，输出的mm将被添加到最后
  ;(4) 输出为ASCII文件
  opt = True
  opt@fout = "./practice/lx2_data/preciptation-JJA.txt"
  write_matrix(mm, "160f7.2", opt)
  
end 
 
 
