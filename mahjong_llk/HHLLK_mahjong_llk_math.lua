--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       mahjong_LLK_math(连连看数学库)
//File Name:    mahjong_LLK_math.h
//Author:       GostYe
//Start Data:   2016.01.19
//Language:     XCode 4.5
//Target:       IOS, Android
/****************************************************************************
-- 使用：（创建对象后）
]]

require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DDefine")

CDMahjongHHLLKLLK = class("CDMahjongHHLLKLLK")
CDMahjongHHLLKLLK.__index = CDMahjongHHLLKLLK

-- 牌的基本数据
DEF_LLK_MJ_WAN        = 1           -- 万   
DEF_LLK_MJ_TIAO       = 2           -- 条
DEF_LLK_MJ_TONG       = 3           -- 筒
-- DEF_LLK_MJ_FENG       = 4           -- 风
-- DEF_LLK_MJ_JIAN       = 5           -- 箭
-- DEF_LLK_MJ_HUA        = 6           -- 花

-- 方向
DEF_DIRECTION_INCALID  = -1          -- 无效方向
DEF_DIRECTION_UP       = 0           -- 上
DEF_DIRECTION_DOWN     = 1           -- 下
DEF_DIRECTION_LEFT     = 2           -- 左
DEF_DIRECTION_RIGHT    = 3           -- 右

----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKLLK:ctor()
    cclog("CDMahjongHHLLKLLK::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjongHHLLKLLK.m_nHHLLKMahjongTotal = 0       -- 自己记录牌总数
CDMahjongHHLLKLLK.m_mapMahjongConfig = {}   -- 麻将难度配置

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKLLK:release()
    cclog("CDMahjongHHLLKLLK::release")
end

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKLLK:init()
    for i = DEF_LLK_MJ_WAN, DEF_LLK_MJ_TONG do
        self.m_mapMahjongConfig[i] = {}
        if i >= DEF_LLK_MJ_WAN and i <= DEF_LLK_MJ_TONG then
            for j = 1, 9 do
                table.insert(self.m_mapMahjongConfig[i], i * 10 + j)
            end
        -- elseif i == DEF_LLK_MJ_FENG then
        --     for j = 1, 4 do
        --         table.insert(self.m_mapMahjongConfig[i], i * 10 + j)
        --     end
        -- elseif i == DEF_LLK_MJ_JIAN then
        --     for j = 1, 3 do
        --         table.insert(self.m_mapMahjongConfig[DEF_LLK_MJ_FENG], i * 10 + j)
        --     end
        -- else
        --     for j = 1, 8 do
        --         table.insert(self.m_mapMahjongConfig[i], i * 10 + j)
        --     end
        end
    end
end

----------------------------------------------------------------------------
---push_back 根据指定位置将数组压入到指定数组
---@param sArray table 指定被压入数组（返回）
---@param sVector table 需要压入的数组
---@param nBegin number 开始位置
---@param nEnd number 结束位置
function CDMahjongHHLLKLLK:push_back( sArray, sVector, nBegin, nEnd)
    if  TABLE_SIZE(sVector) < nEnd then
        return
    end
    if  nBegin and nEnd then
        for i = nBegin, nEnd do
            sArray[TABLE_SIZE(sArray) + 1] = sVector[i]
        end
    end
end

---push_card 将单牌添加入数组
---@param sArray table 指定被添加的数组(返回)
---@param value number 需要添加的牌
function CDMahjongHHLLKLLK:push_card( sArray,value)
    if  sArray and value then
        sArray[TABLE_SIZE(sArray)+1] = value
    end
end

---pop_back 删除数组从数组最后开始
---@param sArray table 被删除的指定数组
---@param count number 删除的数量
function CDMahjongHHLLKLLK:pop_back( sArray, count)
    local size = TABLE_SIZE(sArray)
    if  size == 0 or count > size then
        return
    end
    for i = 1, count do
        size = TABLE_SIZE( sArray)
        table.remove( sArray, size)
    end
end

---pop_array 删除数组从数组中找
---@param sArray table 需要进行删除的数组
---@param sVector table 用于删除的数组
function CDMahjongHHLLKLLK:pop_array( sArray, sVector)
    local size  = TABLE_SIZE(sArray)
    local count = TABLE_SIZE(sVector)

    if  size == 0 or count == 0 then
        return
    end
    for i = 1, count do
        size = TABLE_SIZE(sArray)
        for j = 1, size do
            if  sArray[j] == sVector[i] then
                table.remove( sArray, j)
                break
            end
        end
    end
end

---pop_card 删除数组从数组中找指定的牌（只删除一张相同的牌)
---@param sArray table 被删除的指定数组
---@param card number 要删除的牌
function CDMahjongHHLLKLLK:pop_card( sArray, card)
    local size = TABLE_SIZE(sArray)
    if  size == 0 then
        return
    end
    for i = 1, size do
        if  sArray[i] == card then
            table.remove(sArray, i)
            return
        end
    end
end

-- 获取配置
function CDMahjongHHLLKLLK:getMahjongConfig()
    return self.m_mapMahjongConfig
end

--- Describe what CDMahjongHHLLKLLK:randmSort 随机排序，打乱数组顺序 
-- @param _tArray table-array 需要乱序的数组
-- @return nil
function CDMahjongHHLLKLLK:randmSort(_tArray)
    local nSize = TABLE_SIZE(_tArray)
    if _tArray and nSize > 0 then
        -- 设置随机种子
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
        -- math.randomseed(tostring(socket.gettime()):reverse():sub(1, 6)) 

        local nTemp
        for i, v in ipairs(_tArray) do
            local nPos = math.random(1, TABLE_SIZE(_tArray));    --从10个数中取出一个和a[i]交换，可能是它自己。
            nTemp = _tArray[i];
            _tArray[i] = _tArray[nPos];
            _tArray[nPos] = nTemp;
        end
    end
end

--- Describe what CDMahjongHHLLKLLK:llk 采用A星算法（深度递归，暂停使用）
-- @param _x1 number 起始点x坐标值
-- @param _y1 number 起始点y坐标值
-- @param _x2 number 终点x坐标值
-- @param _y2 number 终点y坐标值
-- @param _arrayPathStr map 找出的路径集合
-- @param _zj number 转角次数
-- @param _fx number 方向
-- @param _dMap table 连连看布局
-- @return nil
function CDMahjongHHLLKLLK:llk(_x1, _y1, _x2, _y2, _arrayPathStr, _zj, _fx, _dMap)
    print("CDMahjongHHLLKLLK:llk")
    -- 转角次数大于2次则寻路失败
    -- 策划同学说，转折次数只能2次
    if _zj > 2 then
        return false
    end

    -- 边界值得评定，超出边界值则失败        
    local checkPointStr = _x1 .. "," .. _y1 
    if not _dMap[checkPointStr] then
        return false
    end

    -- 成功找到目标，返回成功
    if _x1 == _x2 and _y1 == _y2 then
        return true 
    end

    -- 障碍物判定，如果是障碍物则失败
    if _fx ~= DEF_DIRECTION_INCALID and _dMap[checkPointStr].valid and _dMap[checkPointStr].mahjongItem:isVisible() then
        return false
    end

    -- 开始计算四个方向的耗费值
    -- f = g + h
    --  g: 已转角次数 + 即将转角次数
    --  h: 到达目的地至少需要的转角次数 + 到目的地的距离
    local f_l = _zj + ((_fx == DEF_DIRECTION_UP or _fx == DEF_DIRECTION_DOWN) and 1 or 0) +
                (((_x1 - 1) ~= _x2 and _y1 ~= _y2) and 1 or 0 ) +
                1 + math.abs(_x2 - (_x1 - 1)) + math.abs(_y2 - _y1)

    local f_r = _zj + ((_fx == DEF_DIRECTION_UP or _fx == DEF_DIRECTION_DOWN) and 1 or 0) +
                (((_x1 + 1) ~= _x2 and _y1 ~= _y2) and 1 or 0 ) +
                1 + math.abs(_x2 - (_x1 + 1)) + math.abs(_y2 - _y1)

    local f_u = _zj + ((_fx == DEF_DIRECTION_LEFT or _fx == DEF_DIRECTION_RIGHT) and 1 or 0) +
                ((_x1 ~= _x2 and (_y1 - 1) ~= _y2) and 1 or 0 ) +
                1 + math.abs(_x2 - _x1) + math.abs(_y2 - (_y1 - 1))

    local f_d = _zj + ((_fx == DEF_DIRECTION_LEFT or _fx == DEF_DIRECTION_RIGHT) and 1 or 0) +
                ((_x1 ~= _x2 and (_y1 + 1) ~= _y2) and 1 or 0 ) +
                1 + math.abs(_x2 - _x1) + math.abs(_y2 - (_y1 + 1))

    local tmpFStruct = {}
    tmpFStruct[0] = {}
    tmpFStruct[0].f = f_l
    tmpFStruct[0].fx = DEF_DIRECTION_LEFT
    tmpFStruct[0].isCanFind = (_fx ~= DEF_DIRECTION_RIGHT) and true or false
    tmpFStruct[0].offset_x = -1
    tmpFStruct[0].offset_y = 0

    tmpFStruct[1] = {}
    tmpFStruct[1].f = f_r
    tmpFStruct[1].fx = DEF_DIRECTION_RIGHT
    tmpFStruct[1].isCanFind = (_fx ~= DEF_DIRECTION_LEFT) and true or false
    tmpFStruct[1].offset_x = 1
    tmpFStruct[1].offset_y = 0

    tmpFStruct[2] = {}
    tmpFStruct[2].f = f_u
    tmpFStruct[2].fx = DEF_DIRECTION_UP
    tmpFStruct[2].isCanFind = (_fx ~= DEF_DIRECTION_DOWN) and true or false
    tmpFStruct[2].offset_x = 0
    tmpFStruct[2].offset_y = -1 

    tmpFStruct[3] = {}
    tmpFStruct[3].f = f_d
    tmpFStruct[3].fx = DEF_DIRECTION_DOWN
    tmpFStruct[3].isCanFind = (_fx ~= DEF_DIRECTION_UP) and true or false
    tmpFStruct[3].offset_x = 0
    tmpFStruct[3].offset_y = 1

    -- 根据耗费数进行排序
    for i = 1, 3 do
        local tmpSt = {}
        for j = i, 1, -1 do
            if tmpFStruct[j].f < tmpFStruct[j - 1].f then
               tmpSt.f = tmpFStruct[j - 1].f 
               tmpSt.fx = tmpFStruct[j - 1].fx
               tmpSt.isCanFind = tmpFStruct[j - 1].isCanFind
               tmpSt.offset_x = tmpFStruct[j - 1].offset_x
               tmpSt.offset_y = tmpFStruct[j - 1].offset_y

               tmpFStruct[j - 1].f = tmpFStruct[j].f 
               tmpFStruct[j - 1].fx = tmpFStruct[j].fx
               tmpFStruct[j - 1].isCanFind = tmpFStruct[j].isCanFind
               tmpFStruct[j - 1].offset_x = tmpFStruct[j].offset_x
               tmpFStruct[j - 1].offset_y = tmpFStruct[j].offset_y

               tmpFStruct[j].f = tmpSt.f 
               tmpFStruct[j].fx = tmpSt.fx
               tmpFStruct[j].isCanFind = tmpSt.isCanFind
               tmpFStruct[j].offset_x = tmpSt.offset_x
               tmpFStruct[j].offset_y = tmpSt.offset_y
            end
        end
    end

    -- print("=================")
    -- print("x1:",_x1)
    -- print("y1:",_y1)
    -- print("x2:",_x2)
    -- print("y2:",_y2)
    -- print("=================")
    -- for i = 0, 3 do
    --     print("==========tmpFStruct============")
    --     print("f:",tmpFStruct[i].f)
    --     print("fx:",tmpFStruct[i].fx)
    --     print("isCanFind:",tmpFStruct[i].isCanFind)
    --     print("offset_x:",tmpFStruct[i].offset_x)
    --     print("offset_y:",tmpFStruct[i].offset_y)
    --     print("==========tmpFStruct============")
    -- end

    -- 寻路
    for i = 0, 3 do
        if tmpFStruct[i].isCanFind then
            local tmpZj = (_fx ~= tmpFStruct[i].fx and _fx ~= DEF_DIRECTION_INCALID) and _zj + 1 or _zj
            if self:llk(_x1 + tmpFStruct[i].offset_x, _y1 + tmpFStruct[i].offset_y, _x2, _y2, _arrayPathStr, tmpZj, tmpFStruct[i].fx, _dMap) then

                -- 寻路成功后，记录转角点
                if tmpZj > _zj and _arrayPathStr then
                    table.insert(_arrayPathStr, _x1 .. "," .. _y1)
                end
                return true
            end
        end
    end

    return false
end

--- Describe what CDMahjongHHLLKLLK:llk 是否连线 
-- @param p1 number 起始点
-- @param p2 number 终点
-- @param _path array 找出的路径集合
-- @param _arrayMahjong table 连连看布局
-- @return nil
function CDMahjongHHLLKLLK:getLlkPath(p1, p2, _path, _arrayMahjong)
    if not _arrayMahjong then
        return
    end

    local tmpArrayPathStr = {}

    -- 清空该数组，用于保存新的数据结构 x,y
    local tmpPointPath = {}
    local tmpPoint = {}

    -- 计算麻将大小
    _arrayMahjong[p1.X][p1.Y].mahjongItem:getMahjongSize()
    width = _arrayMahjong[p1.X][p1.Y].mahjongItem.m_nHHLLKSizeW
    height = _arrayMahjong[p1.X][p1.Y].mahjongItem.m_nHHLLKSizeH

    local tmpPath = {}
    local arraySize = TABLE_SIZE(_path) 
    for i, v in ipairs(_path) do
        if arraySize == 2 then
            if p1.X == v.X or p1.Y == v.Y then
                table.insert(tmpPath, 1, v)
            else
                table.insert(tmpPath, v)
            end
        else
            table.insert(tmpPath, v)
        end
    end

    --for i, v in ipairs(_path) do
    for i, v in ipairs(tmpPath) do
        tmpPoint = {}
        if not _arrayMahjong[v.X][v.Y].valid then
            if v.X == 1 then
                tmpPoint.X = _arrayMahjong[v.X + 1][v.Y].mahjongItem:getPositionX() - width / 2 - 20 
                tmpPoint.Y = _arrayMahjong[v.X + 1][v.Y].mahjongItem:getPositionY()

            elseif v.Y == 1 then
                tmpPoint.X = _arrayMahjong[v.X][v.Y + 1].mahjongItem:getPositionX() 
                tmpPoint.Y = _arrayMahjong[v.X][v.Y + 1].mahjongItem:getPositionY() + height / 2 + 20 
                
            elseif v.X == TABLE_SIZE(_arrayMahjong) then
                tmpPoint.X = _arrayMahjong[v.X - 1][v.Y].mahjongItem:getPositionX() + width / 2 + 20
                tmpPoint.Y = _arrayMahjong[v.X - 1][v.Y].mahjongItem:getPositionY()

            elseif v.Y == TABLE_SIZE(_arrayMahjong[p1.X]) then
                tmpPoint.X = _arrayMahjong[v.X][v.Y - 1].mahjongItem:getPositionX() 
                tmpPoint.Y = _arrayMahjong[v.X][v.Y - 1].mahjongItem:getPositionY() - height / 2 - 20
            end
        else
            tmpPoint.X = _arrayMahjong[v.X][v.Y].mahjongItem:getPositionX() 
            tmpPoint.Y = _arrayMahjong[v.X][v.Y].mahjongItem:getPositionY()
        end
        table.insert(tmpPointPath, tmpPoint)
    end

    -- 将'起点'与'终点'分别插入路径的'头'与'尾'
    tmpPoint = {}
    tmpPoint.X = _arrayMahjong[p1.X][p1.Y].mahjongItem:getPositionX()
    tmpPoint.Y = _arrayMahjong[p1.X][p1.Y].mahjongItem:getPositionY()
    table.insert(tmpPointPath, 1, tmpPoint)

    tmpPoint = {}
    tmpPoint.X = _arrayMahjong[p2.X][p2.Y].mahjongItem:getPositionX()
    tmpPoint.Y = _arrayMahjong[p2.X][p2.Y].mahjongItem:getPositionY()
    table.insert(tmpPointPath, tmpPoint)

    return tmpPointPath
end

----------------------------------------------------------------------------
-- 折点方法

--- Describe what CDMahjongHHLLKLLK:isCanLigature 是否能连线 
-- @param p1 number 起始点
-- @param p2 number 终点
-- @param itemArray array 二维数组连连看布局
-- @param path array 找出的路径集合
-- @return nil
function CDMahjongHHLLKLLK:isCanLigature(p1, p2, itemArray, path)
    if self:checkOneLine(p1, p2, itemArray) or
        self:checkTwoLine(p1, p2, itemArray, path) or self:checkThreeLine(p1, p2, itemArray, path) then
        -- print("===========isCanLigature==============")
        -- for i, v in ipairs(path) do
        --     print(i..":"..v.X..","..v.Y)
        -- end
        -- print("===========isCanLigature==============")
        return true
    end
    return false
end

--- Describe what CDMahjongHHLLKLLK:checkAllItemCanDestory 检测棋盘是否有可以连接的item项 
-- @param itemArray array 二维数组连连看布局
-- @param path array 找出的路径集合
-- @return nil
function CDMahjongHHLLKLLK:checkAllItemCanDestory(itemArray, path)
    local tmpArr, p1, p2 = {}, {}, {}
    for i, v in ipairs(itemArray) do
        for _i, _v in ipairs(v) do
            -- 提示必需在可视的item中寻找
            if _v.isDisplay then
                -- 以k,v形式存储，方便排除
                local tmpStr = _v.X .. "," .. _v.Y
                tmpArr[tmpStr] = true
                p1.X = _v.X
                p1.Y = _v.Y

                for j, z in ipairs(itemArray) do
                    for _j, _z in ipairs(z) do
                        local _tmpStr = _z.X .. "," .. _z.Y
                        p2.X = _z.X
                        p2.Y = _z.Y
                        if not tmpArr[_tmpStr] and _z.isDisplay then
                            if _z.mahjong == _v.mahjong then
                                if self:checkOneLine(p1, p2, itemArray) or
                                    self:checkTwoLine(p1, p2, itemArray, path) or self:checkThreeLine(p1, p2, itemArray, path) then
                                    -- print("===========checkAllItemCanDestory==============")
                                    -- print("p1:",p1.X .. "," .. p1.Y)
                                    -- print("p2:",p2.X .. "," .. p2.Y)
                                    -- if path then
                                    --     for i, v in ipairs( path ) do
                                    --         print( i..":"..v.X..","..v.Y )
                                    --     end
                                    -- end
                                    -- print("===========checkAllItemCanDestory==============")
                                    return true, p1, p2
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

--- Describe what CDMahjongHHLLKLLK:checkOneLine 两点之间的直线是否可连判断 
-- @param p1 number 起始点
-- @param p2 number 终点
-- @param itemArray array 二维数组连连看布局
-- @return nil
function CDMahjongHHLLKLLK:checkOneLine(p1, p2, itemArray)
    -- 两点为同一点，false
    if p1.X == p2.X and p1.Y == p2.Y then
        return false
    end

    -- 两点不在同一横向或竖向，即不在同一直线上
    if p1.X ~= p2.X and p1.Y ~= p2.Y then
        return false
    end

    -- 确定两点横向或竖向共线后，只要在此方向上有阻隔，则不连通（false）
    -- 两点横向共线
    local offset = 0
    if p1.X == p2.X then
        -- 计算便宜量
        if p1.Y - p2.Y > 0 then
            offset = -1
        else
            offset = 1
        end

        -- 纵向扫描
        for i = p1.Y + offset, p2.Y - offset, offset do
            if not itemArray[p1.X][i] or itemArray[p1.X][i].isDisplay then
                return false
            end
        end
    -- 两点竖向共线
    else 
        -- 计算便宜量
        if p1.X - p2.X > 0 then
            offset = -1
        else
            offset = 1
        end

        -- 横向扫描
        for i = p1.X + offset, p2.X - offset, offset do
            if not itemArray[i][p1.Y] or itemArray[i][p1.Y].isDisplay then
                return false
            end
        end
    end

    -- 在连点共线的方向上没有图片阻隔，true（一线连通）
    return true
end

--- Describe what CDMahjongHHLLKLLK:checkOneLine 2线连接 
-- @param p1 number 起始点
-- @param p2 number 终点
-- @param itemArray array 二维数组连连看布局
-- @param path array 找出的路径集合
-- @return nil
function CDMahjongHHLLKLLK:checkTwoLine(p1, p2, itemArray, path)
    -- 两线连通时，两点组成一个矩形。另外两个顶点A和B即二线连通情况的可能转点
    local A = {X=p1.X, Y=p2.Y}
    local B = {X=p2.X, Y=p1.Y}

    local aIsVisible = itemArray[A.X][A.Y].isDisplay
    local bIsVisible = itemArray[B.X][B.Y].isDisplay

    -- 两顶点都有图，即两顶点都不可用作转点
    if aIsVisible and bIsVisible then
        return false
    end 

    -- A点无图情况
    if not aIsVisible then
        -- p1与A可一线连接，且A与p2可一线连接
        if self:checkOneLine(p1, A, itemArray) and self:checkOneLine(A, p2, itemArray) then
            -- 设置两线连接的转点为A
            if path then
                table.insert(path, A)
            end
            return true
        end
    end

    -- B点无图情况
    if not bIsVisible then
        -- p1与B可一线连接，且B与p2可一线连接
        if self:checkOneLine(p1, B, itemArray) and self:checkOneLine(B, p2, itemArray) then
            -- 设置两线连接的转点为B
            if path then
                table.insert(path, B)
            end
            return true
        end
    end

    -- A、B点都无图，但是在p1通往A、B或A、B通往p2路径上有图片阻隔
    return false
end

-- 计算两点直线距离
--[[
function CDMahjongHHLLKLLK:distance1(p1, p2)
    if p1.X ~= p2.X and p1.Y ~= p2.Y then
        print("两点非同一直线")
    end
    local dis = 0
    if p1.X == p2.X then
        -- 两点同横向
        dis = math.abs(p1.Y - p2.Y)
    else
        -- 两点同纵向
        dis = math.abs(p1.X - p2.X)
    end
    return dis
end

-- 计算两点折线距离
function CDMahjongHHLLKLLK:distance2(p1, p2, itemArray)
    -- 通过调用checkTwoLine来重置tp2，通过tp2来调用distance1
    self:checkTwoLine(p1, p2, itemArray)
    -- 通过tp2做链接，两次调用distance1
    return self:distance1(p1, tp2) + self:distance1(tp2, p2)
end
--]]

--- Describe what CDMahjongHHLLKLLK:checkOneLine 3线连接 
-- @param p1 number 起始点
-- @param p2 number 终点
-- @param itemArray array 二维数组连连看布局
-- @param path array 找出的路径集合
-- @return nil
function CDMahjongHHLLKLLK:checkThreeLine(p1, p2, itemArray, path)
    -- 搜索点
    local A = {X=0,Y=0}

    -- 找到边界值
    local nRow = TABLE_SIZE(itemArray)
    local nColumn = TABLE_SIZE(itemArray[1])

    -- print("==============checkThreeLine==================")
    -- print("nRow:",nRow)
    -- print("nColumn:",nColumn)
    -- print("==============checkThreeLine==================")

    -- 纵向+搜索
    for i = p1.Y + 1, nColumn do
        A.X = p1.X
        A.Y = i

        -- 有图，取消接下来的 横向+ 搜索
        if itemArray[A.X][A.Y].isDisplay then
            break
        else 
            -- A点可与p2二线连通，则A点是转点，放入转点数组
            if self:checkTwoLine(A, p2, itemArray, path) then
                -- table.insert(turnPoint, A)
                if path then
                    table.insert(path, 1, A)
                end
                return true
            end
        end
    end

    -- 纵向-搜索
    for i = p1.Y - 1, 1, -1 do
        A.X = p1.X 
        A.Y = i
        if itemArray[A.X][A.Y].isDisplay then
            break
        else
            if self:checkTwoLine(A, p2, itemArray, path) then
                -- table.insert(turnPoint, A)
                if path then
                    table.insert(path, 1, A)
                end
                return true
            end
        end
    end

    -- 横向+搜索
    for i = p1.X + 1, nRow do
        A.X = i 
        A.Y = p1.Y
        if itemArray[A.X][A.Y].isDisplay then
            break
        else
            if self:checkTwoLine(A, p2, itemArray, path) then
                -- table.insert(turnPoint, A)
                if path then
                    table.insert(path, 1, A)
                end
                return true
            end
        end
    end

    -- 横向-搜索
    for i = p1.X - 1, 1, -1 do
        A.X = i 
        A.Y = p1.Y
        if itemArray[A.X][A.Y].isDisplay then
            break
        else
            if self:checkTwoLine(A, p2, itemArray, path) then
                -- table.insert(turnPoint, A)
                if path then
                    table.insert(path, 1, A)
                end
                return true
            end
        end
    end

    -- 找最优点tp3
    -- 找到了转点
    -- local count = TABLE_SIZE(turnPoint)
    -- if count ~= 0 then 
    --     local p = turnPoint[0]
    --     -- 通过p1和转点p的两点直线距离 和p与p2的两点折线距离来获得
    --     -- p1和p2通过转点p的三点折线距离
    --     -- dis用于获取三点最短距离
    --     local dis = self:distance1(p1, p) + self:distance2(p, p2, itemArray)
    --     for i = 1, count - 1 do
    --         -- 内部_dis，分别获取p1和p2通过不同转点的三点折线距离
    --         local _dis = self:distance1(p1, turnPoint[i]) + self:distance2(turnPoint[i], p2, itemArray);
    --         -- 找到一个所需距离更短的转点turnPoint[i]
    --         if _dis < dis then
    --             dis = _dis
    --             -- p设置为最优转点
    --             p.X = turnPoint[i].X
    --             p.Y = turnPoint[i].Y
    --         end
    --     end

    --     -- 设置tp3为三线连接的转点
    --     tp3.X = p.X
    --     tp3.Y = p.Y

    --     --[[*
    --      * 每次checkTwoLine都会重置tp2，
    --      * 而distance2中调用了此函数，且checkThreeLine函数最后调用的
    --      * checkTwoLine函数产生的tp2也不一定为正确的tp2。因此需要通过
    --      * 再次用最优点与p2找二线连通，来设置正确的tp2
    --     */]]
    --     -- checkTwoLine会自动设置tp2
    --     self:checkTwoLine(tp3, p2, itemArray)
    --     return true
    -- end

    -- 没有找到任何转点，故无三线连通
    return false
end

----------------------------------------------------------------------------
-- 创建连连看数学库
function CDMahjongHHLLKLLK.create()
    cclog("CDMahjongHHLLKLLK.create")
    local   instance = CDMahjongHHLLKLLK.new()
    return  instance
end
