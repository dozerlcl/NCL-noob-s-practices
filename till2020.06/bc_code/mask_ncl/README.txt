拆分区域的脚本part.ncl
其余是：
可参考的shp文件quhua.rar(中国气候带划分)
http://www.resdc.cn/data.aspx?DATAID=243

用到的mask函数：shapefile_utils.ncl 注意调参
http://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl

需要：说明区域的shp文件，待拆分的有经纬度信息的数据，将生成区域信息模板，使用where套用到变量的其他维度上