-----------------------------------------------
--  字符编码的改进过程 ascII -----> GB2312 ------->unicode
--unicode 下 UTF-8 ，utf-16、utf-32

--[[常规来看，中文汉字在utf-8中到底占几个字节，一般是3个字节，最常见的编码方式是1110xxxx 10xxxxxx 10xxxxxx”
字符是否问中文是可以判断的，因为如果是汉字 那么这个字符的第一个字节的高三位（即1110xxxx中的111）一定是111，第四位是0，
所以这个字节换算成数字的话最小值是224（11100000）最大值是238（11101111），
所以如果我们读到一个字节，他的数值介于224与238之间，那么我们就可以判定，这个字节以及其后的两个字节，共三个字节组成一个汉字
]]

--function: 常用于输入时长度的判断(包含中英文判断)
function printStrWidth(str)

	local strLength = #str 
	local width = 0
	local i  = 1 

	while i <= strLength do

		local curByte = string.byte(str,i)
		local byteCount = 1
        if curByte>0 and curByte<=127 then
            byteCount = 1                                           --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                           --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                           --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                           --4字节字符
        end

        local char = string.sub(str, i, i+byteCount-1)
        print(char)                                                         

        i = i + byteCount                                 -- 重置下一字节的索引
        width = width + 1                                 -- 字符的个数（长度）

	end

	print("width------------->",width)
	return width
end

--printStrWidth("Jimmy: 你好,世界!")

-----------------------------------------------