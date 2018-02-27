#!/bin/bash
# author:jsonmess

###################函数体#################
#退出
exitScript(){
    exit 1
}

#导出zip符号表zip
#param:$1 dsym路径
#param:$2 app名称
#param:$3 导出路径
exportDsymFile(){
    #1.指定目录下创建目录
    exportFile="$2.dSYM"
    exportFilePath="$3/$exportFile"
    if [ -d "$exportFilePath" ];then
        echo "导出目录已存在，将直接覆盖！" #由于自动化，所以直接就覆盖了
        rm -r -f  "$exportFilePath"
        #移除原有压缩包
        rm -f "$exportFilePath.zip" 
    fi
    
    mkdir "$exportFilePath"
    #2.拷贝数据
    #2.1 导出
    #2.2 过滤掉非UUID命名的文件（UUID 名称的文件是bitcode重编译的dsym）
    cd "$1"
    for tmp in `ls | egrep "^([0-9a-zA-Z]{8}(\-[0-9a-zA-Z]{4}){3}-[0-9a-zA-Z]{12})|([0-9a-zA-Z]{32})$"`;
    do
      cp -f -r "$tmp" "$exportFilePath/$tmp"
    done
    #2.2 打包成zip
    cd "$3"
    zip "$exportFile.zip" -r "$exportFile"
    rm -r -f "$exportFilePath"
    echo "######导出Dysm 完成#######"
}

 #处理符号表函数
 #param:$1 ArchivePath 
 #param:$2 dsym 目录
 #param:$3 dsym map 目录
 operationMap(){
    dsymFilePath="$1/$2/Contents/Resources/DWARF"
    mapsPath=$3 #符号表map文件的路径
    for binaryFile in `ls "$dsymFilePath"`; 
    do 
        binaryFilePath="$dsymFilePath/$binaryFile"
        # echo $binaryFilePath
        #执行处理命令
        dsymutil --symbol-map "$mapsPath" "$binaryFilePath"
        break 
    done

}

#######################Main入口###################
#1.外部传入xcarchive 路
ArchivePath=$1
ExportPath=$2
echo "传入的路径是------ $ArchivePath"
#1.1判断当前路径是否是xcarchive 有效路径
pathSuffix=${ArchivePath##*.}
if [ "$pathSuffix"x = "xcarchive"x ]; then
    echo "是有效的路径"
 else 
    echo "当前路径不是archive路径，请检查"
    exitScript

fi
#2 获取dSYMs路径 和 BCSymbolMaps路径 
#2.1 获取dSYMs路径
dSYMsPath="${ArchivePath}/dSYMs"
#2.2 获取BCSymbolMaps 路径
bcSymbolMapsPath="${ArchivePath}/BCSymbolMaps"
#2.3 循环遍历dSYMs 下的符号表
for tmp in `ls "$dSYMsPath"`;
do 
   #开始对这个文件 进行处理
    #如果是.dSYM,则处理
   if [ "${tmp##*.}"x = "dSYM"x ]; then
        operationMap "$dSYMsPath" "$tmp" "$bcSymbolMapsPath"
   fi  
done
#2.4 导出
#2.4.1 获取项目名称
AppName="DefaultApp"
for name in `ls "${ArchivePath}/Products/Applications/"`;
do
    AppName=${name%.*}
    break
done
#2.4.2 开始导出
exportDsymFile "${dSYMsPath}" "$AppName" "$ExportPath"
