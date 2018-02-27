# BitCodeDsym
a shell script to solve crash log “__hidden__" problem in Xcode project used bitCod

bitcode 工程 导出 dsym符号表无法正常解析crash log，出现 “__hidden__"



## How to Use （如何使用）

this script need Input Path (xcarchive) and outPut Path (dsym)

we can use like this：
用法如下：


    shell bitCodeDsym.sh \[xcarchive path\] [output dsym path]
    

the output is a zip file named \[you project name\].



