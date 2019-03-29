--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongHHLLKTPGSMath(听牌高手数学库)
//File Name:    HHLLK_mahjong_tpgs_math.h
//Author:       GostYe
//Start Data:   2018.09.12
//Language:     XCode 4.5
//Target:       IOS, Android
/****************************************************************************
-- 使用：（创建对象后）
]]

require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DDefine")

CDMahjongHHLLKTPGSMath = class("CDMahjongHHLLKTPGSMath")
CDMahjongHHLLKTPGSMath.__index = CDMahjongHHLLKTPGSMath

DEF_HHLLK_MJ_WAN        = 1           -- 万   
DEF_HHLLK_MJ_TIAO       = 2           -- 条
DEF_HHLLK_MJ_TONG       = 3           -- 筒
DEF_HHLLK_MJ_FENG       = 4           -- 风
DEF_HHLLK_MJ_JIAN       = 5           -- 箭


----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKTPGSMath:ctor()
    cclog("CDMahjongHHLLKTPGSMath::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjongHHLLKTPGSMath.m_mapHHLLKMahjongConfig = {}        -- 麻将配置
CDMahjongHHLLKTPGSMath.m_mapHHLLKMahjongFlag = {}          -- 麻将基本参数设置
CDMahjongHHLLKTPGSMath.m_arrayHHLLKMahjongTotle = {}       -- 麻将集合

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKTPGSMath:release()
    cclog("CDMahjongHHLLKTPGSMath::release")
end

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKTPGSMath:init()
    -- 导入麻将牌型配置
    if g_pHHLLKGlobalManagment:getLLKMode() == 4 then
        self.m_mapHHLLKMahjongConfig = require( "tpgs_game.tpgs_config")
    else
        self.m_mapHHLLKMahjongConfig = require( "tpgs_game.HHLLK_tpgs_config")
    end

    -- 时间、次数设定
    -- 数据结构：m_mapHHLLKMahjongFlag--table
    -- n_second：难度秒数
    -- n_score：难度初始积分
    -- n_time：难度生命次数
    self.m_mapHHLLKMahjongFlag[1] = {}
    self.m_mapHHLLKMahjongFlag[1].n_second = 20
    self.m_mapHHLLKMahjongFlag[1].n_score = 10
    self.m_mapHHLLKMahjongFlag[1].n_time = 3

    self.m_mapHHLLKMahjongFlag[2] = {}
    self.m_mapHHLLKMahjongFlag[2].n_second = 15
    self.m_mapHHLLKMahjongFlag[2].n_score = 100
    self.m_mapHHLLKMahjongFlag[2].n_time = 2

    self.m_mapHHLLKMahjongFlag[3] = {}
    self.m_mapHHLLKMahjongFlag[3].n_second = 10
    self.m_mapHHLLKMahjongFlag[3].n_score = 1000
    self.m_mapHHLLKMahjongFlag[3].n_time = 1

    self.m_mapHHLLKMahjongFlag[4] = {}
    self.m_mapHHLLKMahjongFlag[4].n_second = 30
    self.m_mapHHLLKMahjongFlag[4].n_score = 1000
    self.m_mapHHLLKMahjongFlag[4].n_time = 3


    local index = 1 
    for i = 1, 9 do
        self.m_arrayHHLLKMahjongTotle[   index] = DEF_HHLLK_MJ_TONG*10+i
        self.m_arrayHHLLKMahjongTotle[ index+1] = DEF_HHLLK_MJ_TIAO*10+i
        self.m_arrayHHLLKMahjongTotle[ index+2] = DEF_HHLLK_MJ_WAN*10+i
        index = index + 3
        if i <= 4 then
            self.m_arrayHHLLKMahjongTotle[ index] = DEF_HHLLK_MJ_FENG*10+i
            index = index + 1
        end
        if i <= 3 then
            self.m_arrayHHLLKMahjongTotle[ index] = DEF_HHLLK_MJ_JIAN*10+i
            index = index + 1
        end
    end
    self:randmSort(self.m_arrayHHLLKMahjongTotle)
end

----------------------------------------------------------------------------
---push_back 根据指定位置将数组压入到指定数组
---@param sArray table 指定被压入数组（返回）
---@param sVector table 需要压入的数组
---@param nBegin number 开始位置
---@param nEnd number 结束位置
function CDMahjongHHLLKTPGSMath:push_back( sArray, sVector, nBegin, nEnd)
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
function CDMahjongHHLLKTPGSMath:push_card( sArray,value)
    if  sArray and value then
        sArray[TABLE_SIZE(sArray)+1] = value
    end
end

---pop_back 删除数组从数组最后开始
---@param sArray table 被删除的指定数组
---@param count number 删除的数量
function CDMahjongHHLLKTPGSMath:pop_back( sArray, count)
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
function CDMahjongHHLLKTPGSMath:pop_array( sArray, sVector)
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
function CDMahjongHHLLKTPGSMath:pop_card( sArray, card)
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

--- Describe what CDMahjongHHLLKTPGSMath:randmSort 随机排序，打乱数组顺序 
-- @param _tArray table-array 需要乱序的数组
-- @return nil
function CDMahjongHHLLKTPGSMath:randmSort(_tArray)
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

----------------------------------------------------------------------------
-- 检查胡牌（递归处理)
-- 参数: 检查的普通牌组,检查的赖子组,是否有将牌,以配成的扑牌组,以配成的将牌组
function CDMahjongHHLLKTPGSMath:checkHuPai( sVecPai, sVecLai,bJiang, sVecSavePai, sVecSaveJiang)

    if  TABLE_SIZE( sVecPai) == 0  and  TABLE_SIZE( sVecLai) == 0 then

        return true
    else

        -- 将牌没有的情况下先找将牌
        if  (not bJiang) and TABLE_SIZE( sVecPai) >= 2 and sVecPai[1] == sVecPai[2] then

            --cclog( "checkHuPai ->1<- (%u),(%u)", sVecPai[1], sVecPai[2])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDelePai))
        end

        -- 三张牌组成刻子
        if  TABLE_SIZE( sVecPai) >= 3 and sVecPai[1] == sVecPai[2] and sVecPai[1] == sVecPai[3] then

            --cclog( "checkHuPai ->2<- (%u),(%u),(%u)", sVecPai[1], sVecPai[2], sVecPai[3])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 3)
            self:push_back( vecNextPai, sVecPai, 4, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
        end

        -- 三张组组成顺子,必须不是风、箭牌
        if  TABLE_SIZE( sVecPai) >= 3 and sVecPai[1] < 41 then

            local pai2 = self:isFindMahjong( sVecPai,  sVecPai[1]+1)
            local pai3 = self:isFindMahjong( sVecPai,  sVecPai[1]+2)
            if  pai2 ~= 0 and pai3 ~= 0 then

                --cclog( "checkHuPai ->3<- (%u),(%u),(%u)", sVecPai[1], pai2, pai3)
                local vecNextPai = {}
                local vecNextLai = {}
                local vecDelePai = {}

                vecDelePai[1] = sVecPai[1]
                vecDelePai[2] = pai2
                vecDelePai[3] = pai3

                self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
                self:pop_array( vecNextPai, vecDelePai)
                self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

                self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
                if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                    return true
                end
                self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            end
        end

        return false
    end
end

-- 参数: sArray数组, 要找的数值
-- 返回具体用了哪张
function CDMahjongHHLLKTPGSMath:isFindMahjong( sArray, mahjong)

    local size = TABLE_SIZE( sArray)

    for i = 1, size do

        if  sArray[i] == mahjong then
            return mahjong
        end

    end
    return 0
end

-- 搜索指定对象是否存在
-- 参数: sArray数组, 要找的数值
function CDMahjongHHLLKTPGSMath:isFind( sArray, mahjong)

    local size = TABLE_SIZE( sArray)

    for i = 1, size do

        if  sArray[i] == mahjong then
            return true
        end
    end
    return false
end

--张数判断 sArray(数量:13张)
function CDMahjongHHLLKTPGSMath:isMoreThanFour( sArray, mahjong)

    local size = TABLE_SIZE( sArray)
    local count = 0
    for i = 1, size do
        if sArray[i] == mahjong then
            count = count +1
        end
    end
    if count >3 then
        return true
    end
    return false
end


    -- 从小到大数值排序
function mahjong_tpgs_sort_stb( a, b)
    return a < b
end
-- 麻将组由小到大排列
-- 参数: 牌列表(牌结构(mahjong))
function CDMahjongHHLLKTPGSMath:defMahjongSort_stb( mahjongs)
    table.sort( mahjongs, mahjong_tpgs_sort_stb)
end

function CDMahjongHHLLKTPGSMath:checkCanHu(MahArr,touchMah)

    local  mahjong = {
        11,12,13,14,15,16,17,18,19,
        21,22,23,24,25,26,27,28,29,
        31,32,33,34,35,36,37,38,39,
        41,42,43,44,
        51,52,53
    }

    local curArr = {}
    self:push_back(curArr,MahArr,1,TABLE_SIZE(MahArr))

    self:push_card(curArr,touchMah)

    local saveLastMah = {}
    local sVecSavePai = {}
    local sVecSaveJiang = {}
    local sVecLai = {}
    --因为没有癞子无需分离
    for i = 1 ,34 do
        local tempArr = {}
        self:push_back(tempArr,curArr,1,TABLE_SIZE(curArr))
        self:push_card(tempArr,mahjong[i])
        self:defMahjongSort_stb(tempArr)
        if self:checkHuPai(tempArr,sVecLai,false,sVecSavePai,sVecSaveJiang) then
            self:push_card(saveLastMah,mahjong[i])
        end
    end

    if  TABLE_SIZE(saveLastMah) > 0 then
        return true , saveLastMah
    else
        return false
    end
end



----------------------------------------------------------------------------
-- 随机抓取一组麻将数据
function CDMahjongHHLLKTPGSMath:getRandmMahjongConfig()
    -- 设置随机种子
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))

    -- 获取外层index
    local nTmpOne = math.random(1, TABLE_SIZE(self.m_mapHHLLKMahjongConfig))

    -- 获取内层index
    local nTmpTwo = math.random(1, TABLE_SIZE(self.m_mapHHLLKMahjongConfig[nTmpOne]) - 1)

    -- 定义返回的数据
    -- 数据结构：
    -- t_TingMj：牌组所胡牌数组
    -- t_t_ShowMj：牌组展示的听牌数组
    -- t_Index：定位
    -- t_SelectMj：胡牌选择组
    local tTmpMahjong = {}

    -- 压入听牌数据
    tTmpMahjong.t_TingMj = {}
    self:push_back(tTmpMahjong.t_TingMj, self.m_mapHHLLKMahjongConfig[nTmpOne][0], 1, TABLE_SIZE(self.m_mapHHLLKMahjongConfig[nTmpOne][0])) 

    -- 压入展示牌组，并将展示牌组乱序
    tTmpMahjong.t_ShowMj = {}
    self:push_back(tTmpMahjong.t_ShowMj, self.m_mapHHLLKMahjongConfig[nTmpOne][nTmpTwo], 1, TABLE_SIZE(self.m_mapHHLLKMahjongConfig[nTmpOne][nTmpTwo]))
    self:randmSort(tTmpMahjong.t_ShowMj)

    -- 记录配置项的index（用于定位错误用）
    tTmpMahjong.t_Index = {nTmpOne, nTmpTwo}

    -- 生成18项选择牌
    tTmpMahjong.t_SelectMj = {}
    local arrayTmpMj = {}
    self:push_back(arrayTmpMj, self.m_arrayHHLLKMahjongTotle, 1, TABLE_SIZE(self.m_arrayHHLLKMahjongTotle))

    local nTmpTingNum = TABLE_SIZE(tTmpMahjong.t_TingMj)
    self:push_back(tTmpMahjong.t_SelectMj, tTmpMahjong.t_TingMj, 1, nTmpTingNum)
    local nMaxNum = 9 * 2 - nTmpTingNum
    local nIndex = 1
    while nIndex <= nMaxNum do
        local nSelectIndex = math.random(1, TABLE_SIZE(arrayTmpMj))
        local nTmpMjValue = arrayTmpMj[nSelectIndex]
        local bTmpIsSelect = false
        for i, v in ipairs( tTmpMahjong.t_SelectMj ) do
            if v == nTmpMjValue then
                bTmpIsSelect = true
                break
            end
        end

        if not bTmpIsSelect then
            nIndex = nIndex + 1
            self:push_card(tTmpMahjong.t_SelectMj, nTmpMjValue)
        end
    end
    self:randmSort(tTmpMahjong.t_SelectMj)

    return tTmpMahjong
end

-- 获取积分
function CDMahjongHHLLKTPGSMath:getScore(_flag, _leftSecond)
    local tmpScore = 0
    if  self.m_mapHHLLKMahjongFlag[_flag] then
        tmpScore = self.m_mapHHLLKMahjongFlag[_flag].n_score * _leftSecond
    end

    return tmpScore
end

-- 获取配置数据
function CDMahjongHHLLKTPGSMath:getFlagConfig(_flag)
    local tmpSecond = 0
    local tmpTime = 0

    if  self.m_mapHHLLKMahjongFlag[_flag] then
        tmpSecond = self.m_mapHHLLKMahjongFlag[_flag].n_second
        tmpTime = self.m_mapHHLLKMahjongFlag[_flag].n_time
    end

    return tmpSecond,tmpTime
end

-- 获取对应难度的倒计时
function CDMahjongHHLLKTPGSMath:getFlagSecondConfig(_flag)
    local tmpSecond = 0

    if  self.m_mapHHLLKMahjongFlag[_flag] then
        tmpSecond = self.m_mapHHLLKMahjongFlag[_flag].n_second
    end

    return tmpSecond
end
----------------------------------------------------------------------------
-- 对应模式时间的减少,每10关减少1秒时间，至少5秒
function CDMahjongHHLLKTPGSMath:reduceTime(_flag)
    if  self.m_mapHHLLKMahjongFlag[_flag] then
        self.m_mapHHLLKMahjongFlag[_flag].n_second = self.m_mapHHLLKMahjongFlag[_flag].n_second-1
        if self.m_mapHHLLKMahjongFlag[_flag].n_second < 5 then
            self.m_mapHHLLKMahjongFlag[_flag].n_second = 5
        end
    end
end
----------------------------------------------------------------------------
-- 创建连连看数学库
function CDMahjongHHLLKTPGSMath.create()
    cclog("CDMahjongHHLLKTPGSMath.create")
    local   instance = CDMahjongHHLLKTPGSMath.new()
    return  instance
end
