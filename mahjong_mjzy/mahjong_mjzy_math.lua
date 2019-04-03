--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongMJZY 湖北江陵晃晃数学库
//File Name:    mahjong_jlhh_math.h
//Author:       GostYe
//Start Data:   2018.05.10
//Language:     XCode 9.3
//Target:       IOS, Android
/****************************************************************************
-- 使用：（创建对象后）
    1). randomSort 等于洗牌
    2). getMahjong 等于获取一张牌(参数 从前还是从后)
    3). canHuPai   检查是否可以胡牌（摸牌后自己判断，如果别人打牌判断可以调用canHuPai_WithOther）
    4). canTingPai 检查是否听牌
]]

require(REQUIRE_PATH.."DCCBLayer")
require(REQUIRE_PATH.."DDefine")

CDMahjongMJZY = class("CDMahjongMJZY")
CDMahjongMJZY.__index = CDMahjongMJZY

DEF_MJZY_MJ_MAX          = 136         -- 牌总数
DEF_MJZY_MJ_NUM_MAX      = 9           -- 基本牌最大数
DEF_MJZY_MAHJONG_SECTION = 10          -- 牌数范围

DEF_MJZY_MJ_WAN          = 1           -- 万   
DEF_MJZY_MJ_TIAO         = 2           -- 条
DEF_MJZY_MJ_TONG         = 3           -- 筒
DEF_MJZY_MJ_FENG         = 4           -- 风
DEF_MJZY_MJ_JIAN         = 5           -- 箭

DEF_MJZY_TYPE_TOTAL      = 3           -- 牌类型总数

DEF_MJZY_MJ_MIN          = 2           -- 手上牌剩余最少数量

DEF_MJZY_NAIZI_MAX       = 4           -- 最大赖子数量
DEF_MJZY_NAIZI_ERR       = 99          -- 需要赖子数量的错误

DEF_MJZY_PENG            = 1           -- 碰
DEF_MJZY_GANG            = 2           -- 杠
DEF_MJZY_HU              = 3           -- 胡
DEF_MJZY_ZIMO            = 4           -- 自摸
DEF_MJZY_CHAOTIAN        = 5           -- 朝天
DEF_MJZY_BUZHUOCHONG     = 6           -- 不捉铳
DEF_MJZY_QIANGXIAO       = 7           -- 抢笑
DEF_MJZY_CHI             = 8           -- 吃
DEF_MJZY_FANGFENG        = 9           -- 放风

DEF_MJZY_TYPE_ZM         = 215         -- 自摸
DEF_MJZY_TYPE_ZC         = 216         -- 捉铳
DEF_MJZY_TYPE_FC         = 217         -- 放铳
DEF_MJZY_TYPE_AG         = 209         -- 暗杠
DEF_MJZY_TYPE_MG         = 210         -- 明杠
----------------------------------------------------------------------------
-- 构造函数
function CDMahjongMJZY:ctor()
    cclog("CDMahjongMJZY::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjongMJZY.m_sMahjongs     = nil  -- 麻将牌组(这里只有万、条、筒)
CDMahjongMJZY.m_nForwardIndex = 0    -- 顺向取牌索引
CDMahjongMJZY.m_nReverseIndex = 0    -- 逆向取牌索引

CDMahjongMJZY.m_nMahjongLaiZi = 0    -- 赖子牌
CDMahjongMJZY.m_nMahjongFan   = 0    -- 翻牌(只有三张)

CDMahjongMJZY.m_nMahjongTotal = DEF_MJZY_MJ_MAX    -- 自己记录牌总数
CDMahjongMJZY.m_bFlagPiao     = false -- 是否有人飘(杠)过赖子

----------------------------------------------------------------------------
-- 初始化(修改）
function CDMahjongMJZY:init()
    self.m_sMahjongs = {}

    -- 牌数值定义
    local index = 0
    for i = 1, DEF_MJZY_MJ_NUM_MAX do
        for j = 1, 4 do

            -- 万、条、筒
            self.m_sMahjongs[index]     = DEF_MJZY_MJ_TONG * DEF_MJZY_MAHJONG_SECTION + i
            self.m_sMahjongs[index + 1] = DEF_MJZY_MJ_TIAO * DEF_MJZY_MAHJONG_SECTION + i
            self.m_sMahjongs[index + 2] = DEF_MJZY_MJ_WAN  * DEF_MJZY_MAHJONG_SECTION + i
            index = index + 3

            -- 风
            if  i <= 4 then
                self.m_sMahjongs[index] = DEF_MJZY_MJ_FENG*10+i
                index = index + 1
            end
            -- 箭
            if  i <= 3 then
                self.m_sMahjongs[index] = DEF_MJZY_MJ_JIAN*10+i
                index = index + 1
            end
        end
    end
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongMJZY:release()
    cclog("CDMahjongMJZY::release")
end

----------------------------------------------------------------------------
-- 随机赖子牌
function CDMahjongMJZY:randomLaiZi()
    local random_num = math.random(0, DEF_MJZY_MJ_MAX - 1)

    -- 先随机翻牌
    local fan = self.m_sMahjongs[random_num]
    self:setMahjongFan(fan)

    -- 赖子是翻牌的下一张，但是翻牌如果是9那么赖子就是1
    local laizi = fan + 1
    if  laizi % 10 == 0 then
        laizi = laizi - 10 + 1
    else
        -- TODO:如果是箭牌（红中）
    end
    self:setMahjongLaiZi(laizi)

    -- 从牌库中删除一张翻牌
    local count = TABLE_SIZE(self.m_sMahjongs) - 1
    local frist = self.m_sMahjongs[0]
    self.m_sMahjongs[0] = fan
    for i = 1, count do
        if  self.m_sMahjongs[i] == fan then
            self.m_sMahjongs[i] = frist
            self.m_nForwardIndex = self.m_nForwardIndex + 1
            break
        end
    end
end
----------------------------------------------------------------------------
-- 随机排序
function CDMahjongMJZY:randomSort()
    cclog("CDMahjongMJZY::randomSort")

    self.m_nForwardIndex = 0
    self.m_nReverseIndex = DEF_MJZY_MJ_MAX - 1

    local index = 0
    local random_num = 0
    for i = 0, DEF_MJZY_MJ_MAX - 1 do
        index = self.m_sMahjongs[i]
        random_num = math.random(0, DEF_MJZY_MJ_MAX - 1)
        self.m_sMahjongs[i] = self.m_sMahjongs[random_num]
        self.m_sMahjongs[random_num] = index
    end

    self:randomLaiZi()
    self:setFlagPiao(false)
end

----------------------------------------------------------------------------
-- 随机打乱牌组顺序
function CDMahjongMJZY:randomMahjongs( mahjongs)
    local mahjong = 0
    local size = TABLE_SIZE( mahjongs)
    local random_idx = 0

    for i = 1, size do
        mahjong = mahjongs[i]
        random_idx = math.random(1, size)
        mahjongs[i] = mahjongs[random_idx]
        mahjongs[random_idx] = mahjong
    end
end

----------------------------------------------------------------------------
-- 设置/获取赖子牌
function CDMahjongMJZY:setMahjongLaiZi(laizi)
    self.m_nMahjongLaiZi = laizi
end
function CDMahjongMJZY:getMahjongLaiZi()
    return self.m_nMahjongLaiZi
end

----------------------------------------------------------------------------
-- 设置/获取赖皮牌(即翻出的牌)
function CDMahjongMJZY:setMahjongFan(fan)
    self.m_nMahjongFan = fan
end
function CDMahjongMJZY:getMahjongFan()
    return self.m_nMahjongFan
end

----------------------------------------------------------------------------
-- 设置/获取是否飘过赖子牌
function CDMahjongMJZY:setFlagPiao( piao)
    self.m_bFlagPiao = piao
end
function CDMahjongMJZY:getFlagPiao()
    return self.m_bFlagPiao
end

----------------------------------------------------------------------------
-- 获取牌根据索引
-- 参数: 是否顺序(否就是逆向获取)
-- 返回: 0失败（没有牌)
function CDMahjongMJZY:getMahjong(forward)
    if  forward == nil then
        forward = true
    end

    local index = 0
    if  forward then
        if  self.m_nForwardIndex > self.m_nReverseIndex then
            return 0
        end
        index = self.m_nForwardIndex
        self.m_nForwardIndex = self.m_nForwardIndex + 1
        return self.m_sMahjongs[index]
    else
        if  self.m_nReverseIndex < self.m_nForwardIndex then
            return 0
        end
        index = self.m_nReverseIndex
        self.m_nReverseIndex = self.m_nReverseIndex - 1
        return self.m_sMahjongs[index]
    end
end

----------------------------------------------------------------------------
-- 获取麻将剩余总数
-- 返回: 数量
function CDMahjongMJZY:getMahjongSize()
    local size = self.m_nReverseIndex - self.m_nForwardIndex + 1
    if  size <= 0 then
        return 0
    end
    return size
end

----------------------------------------------------------------------------
-- 获取麻将牌面数值
-- 参数: 卡牌原始数值
-- 返回: 类型(参考第26～28行定义), 数值(1~9)
function CDMahjongMJZY:getMahjongNumber(mahjong)
    return math.floor(mahjong * 0.1), mahjong % DEF_MJZY_MAHJONG_SECTION
end

----------------------------------------------------------------------------
-- 设置／获取／减少当前麻将牌总数
function CDMahjongMJZY:mahjongTotal_set(total)
    if  total == nil then
        total = DEF_MJZY_MJ_MAX
    end

    self.m_nMahjongTotal = total
end
function CDMahjongMJZY:mahjongTotal_get()
    return self.m_nMahjongTotal
end
function CDMahjongMJZY:mahjongTotal_lower( num)
    if  num == nil then
        num = 1
    end

    self.m_nMahjongTotal = self.m_nMahjongTotal - num
    if  self.m_nMahjongTotal < 0 then
        self.m_nMahjongTotal = 0
    end
    return self.m_nMahjongTotal
end

----------------------------------------------------------------------------
-- 各种排序函数
    -- 从小到大卡牌排序
function mahjong_MJZY_comps_stb( a, b)
    return a.mahjong < b.mahjong
end
    -- 从大到小卡牌排序
function mahjong_MJZY_comps_bts( a, b)
    return a.mahjong > b.mahjong
end
    -- 从小到大数值排序
function mahjong_MJZY_sort_stb( a, b)
    return a < b
end
    -- 从大到小数值排序
function mahjong_MJZY_sort_bts( a, b)
    return a > b
end

----------------------------------------------------------------------------
-- 麻将组由小到大排列
-- 参数: 牌列表(牌结构(mahjong))
function CDMahjongMJZY:defMahjongSort_stb(mahjongs)
    table.sort(mahjongs, mahjong_MJZY_sort_stb)
end

----------------------------------------------------------------------------
-- 麻将组由大到小排列
-- 参数: 牌列表(牌结构(mahjong))
function CDMahjongMJZY:defMahjongSort_bts(mahjongs)
    table.sort(mahjongs, mahjong_MJZY_sort_bts)
end

----------------------------------------------------------------------------
-- 牌排列从小到大
-- 参数: 牌列表(牌结构(mahjong,index))
function CDMahjongMJZY:mahjongSort_stb(mahjongs)
    table.sort(mahjongs, mahjong_MJZY_comps_stb)
end

----------------------------------------------------------------------------
-- 牌排列从大到小
-- 参数: 牌列表(牌结构(mahjong,index))
function CDMahjongMJZY:mahjongSort_bts(mahjongs)
    table.sort(mahjongs, mahjong_MJZY_comps_bts)
end

--＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊赖子胡牌规则＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
--是否可以放风
--参数：点选的牌组
function CDMahjongMJZY:canFangFeng(mahjongs)
    if TABLE_SIZE(mahjongs) ~= 3 then
        return false
    end

    local arrOneTiao = {}
    local arrFengMah = {}
    local arrJianMah = {}
    local hunzi = self:getMahjongLaiZi()

    for i,v in pairs(mahjongs) do
        if v == 21 then
            table.insert(arrOneTiao,v)
        elseif v <50 and v > 40 then
            if not arrFengMah[v] then
                arrFengMah[v] = {}
            end
            table.insert(arrFengMah[v],v)
        elseif v>50 then
            if not arrJianMah[v] then
                arrJianMah[v] = {}
            end
            table.insert(arrJianMah[v],v)
        end
    end

    -- 混子是1条时
    if hunzi == 21 then
        if self:getTableSize(arrJianMah) == 3 or self:getTableSize(arrFengMah) == 3 then
            return true
        end
    else
        if TABLE_SIZE(arrOneTiao)== 3 then
            return true
        end

        if hunzi >40 and hunzi < 50 then
            if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) == 3) and not arrFengMah[hunzi] then
                return true
            end

            if (self:getTableSize(arrJianMah) + TABLE_SIZE(arrOneTiao) == 3) then
                return true
            end

        elseif hunzi > 50 then
            if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) == 3) then
                return true
            end
        else
            if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) == 3) or (self:getTableSize(arrJianMah) + TABLE_SIZE(arrOneTiao) == 3) then
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------------------
--arr 二维
function CDMahjongMJZY:getTableSize(arr)
    if type(arr) ~= "table" then
        return 0
    end

    local count  = 0
    for i,v in pairs(arr) do
        if type(v) == "table" then
            count = count +1
        end
    end
    return count
end

----------------------------------------------------------------------------
--保存可以放风的牌
-- 手牌 
function CDMahjongMJZY:saveFangFengMah(mahjongs)
    local curMahArr = self:getValueFromArr(mahjongs)

    local hunzi = self:getMahjongLaiZi()
    local saveArr = {}

    local arrFengMah = {}
    local arrJianMah = {}
    local arrOneTiao = {}
    for i,v in pairs(curMahArr) do

        if v == 21 then
            arrOneTiao[TABLE_SIZE(arrOneTiao)+1] = v
        elseif v>40 and v < 50 then
            if not arrFengMah[v] then
                arrFengMah[v]= {}
            end
            table.insert(arrFengMah[v],v) 
        elseif v >50 then
            if not arrJianMah[v] then
                arrJianMah[v] = {}
            end
            table.insert(arrJianMah[v],v)
        end
    end
    --混子是1条时
    if  hunzi == 21 then
        if self:getTableSize(arrFengMah) >= 3  then
            for i,v in pairs(arrFengMah) do
                self:push_back(saveArr,v,1,TABLE_SIZE(v))
            end
        end

        if self:getTableSize(arrJianMah) >=3 then
            for i,v in pairs(arrJianMah) do
                self:push_back(saveArr,v,1,TABLE_SIZE(v))
            end
        end
    else
        if hunzi > 50 then
            if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) >= 3) then
                for i,v in pairs(arrFengMah) do
                    self:push_back(saveArr,v,1,TABLE_SIZE(v)) 
                end
                self:push_back(saveArr,arrOneTiao,1,TABLE_SIZE(arrOneTiao))
            end
        elseif hunzi > 40 and hunzi < 50 then
            if (self:getTableSize(arrJianMah) + TABLE_SIZE(arrOneTiao) >= 3) then
                for i,v in pairs(arrJianMah) do
                    self:push_back(saveArr,v,1,TABLE_SIZE(v))
                end
            end

            if not arrFengMah[hunzi] then
                if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) >=3 ) then
                    for i,v in pairs(arrFengMah) do
                        self:push_back(saveArr,v,1,TABLE_SIZE(v))
                    end
                end
            else
                if (self:getTableSize(arrFengMah) + TABLE_SIZE(arrOneTiao) >= 4 ) then
                    for i,v in pairs(arrFengMah) do
                        if i ~= hunzi then
                            self:push_back(saveArr,v,1,TABLE_SIZE(v))
                        end
                    end
                end
            end
            self:push_back(saveArr,arrOneTiao,1,TABLE_SIZE(arrOneTiao))
        else
           
            if (self:getTableSize(arrFengMah)+TABLE_SIZE(arrOneTiao) >= 3) then
                for i,v in pairs(arrFengMah) do
                    dumpArray(v)
                    self:push_back(saveArr,v,1,TABLE_SIZE(v))
                end
            end

            if (self:getTableSize(arrJianMah)+TABLE_SIZE(arrOneTiao) >=3) then
                for i,v in pairs(arrJianMah) do
                    self:push_back(saveArr,v,1,TABLE_SIZE(v))
                end
            end

            self:push_back(saveArr,arrOneTiao,1,TABLE_SIZE(arrOneTiao))
        end
    end

    return saveArr
end
----------------------------------------------------------------------------
--判断是否符合的跑风的逻辑 , 获取跑风打出牌的类型
--特殊情况，放3张小鸡时 要由第4张打出的牌判断到底用 风跑 还是用 箭跑
function CDMahjongMJZY:judgePaoFengMah(fangFengMahs)
  
    local bPaoFType= 0
    local countOneTiao = 0
    for i,v in ipairs(fangFengMahs) do
        if v >50 then
            bPaoFType = 2
            break
        elseif v >40 and v<50 then
            bPaoFType = 1
            break
        elseif v == 21 then
            countOneTiao = countOneTiao+1
        end
    end

    if countOneTiao == 3 then
        bPaoFType = 3
    end

    return bPaoFType
end
----------------------------------------------------------------------------
--参数：手牌，放风得到的类型，第三个参数在 paoFengType为3 时才有用
-- 1.风牌 2.箭牌 3.3个小鸡类型，要看打出的第四张牌类型
function CDMahjongMJZY:findPaoFMahByType(handCards,paoFengType,mahjong)
    local curMahArr = self:getValueFromArr(handCards)

    print("CDMahjongMJZY:findPaoFMahByType")
    dumpArray(curMahArr)

    local saveArr = {}
    if paoFengType == 1 then
        for i,v in ipairs(curMahArr) do
            if v >40 and v <50 and  v ~= self:getMahjongLaiZi() then
                self:push_mahjong(saveArr,v)
            end
        end
    elseif paoFengType == 2 then
        for i,v in ipairs(curMahArr) do
            if v >50 and  v ~= self:getMahjongLaiZi() then
                self:push_mahjong(saveArr,v)
            end
        end
    elseif paoFengType == 3 then
        if mahjong == 0 then
            for i,v in ipairs(curMahArr) do
                if v >40 and v ~= self:getMahjongLaiZi() then
                    self:push_mahjong(saveArr,v)
                end
            end
        else
            if mahjong >50 then
                for i,v in ipairs(curMahArr) do
                    if v >50 and v ~= self:getMahjongLaiZi() then
                        self:push_mahjong(saveArr,v)
                    end
                end
            else
                for i,v in ipairs(curMahArr) do
                    if v >40 and v <50 and v ~= self:getMahjongLaiZi() then
                        self:push_mahjong(saveArr,v)
                    end
                end
            end
        end
    end
    return saveArr
end
----------------------------------------------------------------------------
---push_mahjong 拆分普通牌和赖子牌
---@param mahjongs table mahjongs需要拆分的牌组(mahjong, index)
---@return table, table 普通牌组，赖子牌组
function CDMahjongMJZY:getArray_Pai_Lai(mahjongs)
    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE(mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do
        if  mahjongs[i].mahjong ~= laizi then
            sVecPai[TABLE_SIZE(sVecPai) + 1] = mahjongs[i].mahjong
        else
            sVecLai[TABLE_SIZE(sVecLai) + 1] = laizi
        end
    end

    return sVecPai, sVecLai
end

---push_mahjong 拆分普通牌和赖子牌
---@param mahjongs table 需要拆分的牌组数字
---@return table, table 拆分后的普通牌组，赖子组
function CDMahjongMJZY:getArray_Pai_Lai_ex(mahjongs)
    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE(mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do
        if  mahjongs[i] ~= laizi then
            sVecPai[TABLE_SIZE(sVecPai) + 1] = mahjongs[i]
        else
            sVecLai[TABLE_SIZE(sVecLai) + 1] = laizi
        end
    end

    return sVecPai, sVecLai
end

----------------------------------------------------------------------------
---push_mahjong 拆分普通牌和赖子牌
---@param mahjongs table 需要拆分的牌组(数字)
---@return table, table 拆分后的普通牌组，赖子组
function CDMahjongMJZY:getArrayDef_Pai_Lai(mahjongs)
    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE(mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do
        if  mahjongs[i] ~= laizi then
            sVecPai[TABLE_SIZE(sVecPai) + 1] = mahjongs[i]
        else
            sVecLai[TABLE_SIZE(sVecLai) + 1] = laizi
        end
    end

    return sVecPai, sVecLai
end

----------------------------------------------------------------------------
---push_mahjong 压入数组到数组最后
---@param sArray table 最后返回的数组
---@param sVector table 用于挑选的数组
---@param nBegin number 开始的位置
---@param nEnd number 结束位置
function CDMahjongMJZY:push_back(sArray, sVector, nBegin, nEnd)
    local count = TABLE_SIZE(sVector)
    if  count == 0 or count < nEnd then
        return
    end

    for i = nBegin, nEnd do
        sArray[TABLE_SIZE(sArray) + 1] = sVector[i]
    end
end

----------------------------------------------------------------------------
---push_mahjong 删除数组从数组最后开始
---@param sArray table 最后返回的数组
---@param count number 删除数量
function CDMahjongMJZY:pop_back(sArray, count)
    local size = TABLE_SIZE(sArray)
    if  size == 0 or count > size then
        return
    end

    for i = 1, count do
        size = TABLE_SIZE(sArray)
        table.remove(sArray, size)
    end
end

----------------------------------------------------------------------------
---push_mahjong 删除数组从数组中找
---@param sArray table 最后返回的数组
---@param sVector table 用于删除的数组
function CDMahjongMJZY:pop_array(sArray, sVector)
    local size  = TABLE_SIZE(sArray)
    local count = TABLE_SIZE(sVector)

    if  size == 0 or count == 0 then
        return
    end

    for i = 1, count do
        size = TABLE_SIZE(sArray)
        for j = 1, size do
            if  sArray[j] == sVector[i] then
                table.remove(sArray, j)
                break
            end
        end
    end
end

---push_mahjong 将一张牌压入一个数组
---@param sArray table 最后返回的数组
---@param mahjong number 需要压入的牌
function CDMahjongMJZY:push_mahjong(sArray, mahjong)
    if sArray and mahjong then
        sArray[TABLE_SIZE(sArray) + 1] = mahjong
    end
end

----------------------------------------------------------------------------
---pop_mahjong 删除数组从数组中找指定的牌（只删除一张相同的牌)
---@param sArray table 最后返回的数组
---@param mahjong number 要删除的牌
---@return boolean 是否成功删除
function CDMahjongMJZY:pop_mahjong(sArray, mahjong)
    local size = TABLE_SIZE(sArray)
    if  size == 0 then
        return false
    end

    for i = 1, size do
        if  sArray[i] == mahjong then
            table.remove(sArray, i)
            return true
        end
    end

    return false
end

---pop_allMahjong 弹空指定牌组里的牌
---@param sArray table 需要弹牌的牌组
---@param mahjongs table 需要弹出的牌的牌组
function CDMahjongMJZY:pop_allMahjong(sArray, mahjongs)
    local size = TABLE_SIZE(mahjongs)

    for i = 1, size do
        for j = 1, TABLE_SIZE(sArray) do
            if  sArray[j] == mahjongs[i] then
                table.remove(sArray, j)
            end
        end
    end
end

---getArray_hupai 搜索指定对象是否存在
---@param sArray table 胡牌组
---@param mahjong number 最后胡的牌
-- @param 是否是对对胡还是七对胡
---@return table, table sParray前半组, sBArray后半组

function CDMahjongMJZY:getArray_hupai(sArray, mahjong,isDDH)
    if isDDH then
        local size = TABLE_SIZE( sArray)
        local sParray = {} 
        local sBarray = {}
    
        local find_idx = 0
        for i = 1, size do
            if  sArray[i] == mahjong then
                find_idx = i
                break
            end
        end
    
        if  find_idx ~= 0 then
            local mod = find_idx % 3
            local b_idx = 0
            local e_idx = 0
            if  mod == 0 then
                b_idx = find_idx - 2
                e_idx = find_idx
            elseif mod == 1 then
                b_idx = find_idx
                e_idx = find_idx + 2
            else
                b_idx = find_idx - 1
                e_idx = find_idx + 1
            end
            if  e_idx > size then
                e_idx = size
            end
    
            for i = 1, size do
                if  i >= b_idx and i <= e_idx then
                    sBarray[TABLE_SIZE(sBarray) + 1] = sArray[i]
                else
                    sParray[TABLE_SIZE(sParray) + 1] = sArray[i]
                end
            end
        else
            self:push_back(sBarray, sArray, 1, TABLE_SIZE(sArray))
        end
        return sParray, sBarray
    else

        
        local size = TABLE_SIZE( sArray)
        local sParray = {} 
        local sBarray = {}
        local curArr = {}
        self:push_back(curArr,sArray,1,TABLE_SIZE(sArray))
        self:pop_mahjong(curArr,mahjong)

        local curArrSize = TABLE_SIZE(curArr)
        local savePai = {}
        local saveJiang = {}
        local bCheck = false
        local bJiang = false
        local index = 1
        for i = 1 ,curArrSize do
            saveJiang = {}
            self:push_mahjong(saveJiang,mahjong)
            self:push_mahjong(saveJiang,curArr[i])

            bJiang = self:checkIsJiang(saveJiang)
            
            local temp = {}
            self:push_back(temp,curArr,1,TABLE_SIZE(curArr))
            self:pop_mahjong(temp,curArr[i])
           
            local sVecPai,sVecLai = self:getArray_Pai_Lai_ex(temp)
            self:defMahjongSort_stb(sVecPai)
            bCheck = self:checkSevenJiang(sVecPai,sVecLai,savePai) 
            print("bCheck-------------->",bCheck)
            if bCheck and bJiang then
                sParray[index] = {}
                sBarray[index] = {}
                self:push_mahjong(sBarray[index],curArr[i])
                self:push_mahjong(sBarray[index],mahjong)
                sParray[index] = savePai
                index = index +1
            end
            savePai = {}
        end

        print("----------------111111-----------------")
        local bFindSame = false
        local findIndex = 0
        for i,v in ipairs(sBarray) do
            dumpArray(v)
            if v[1] and v[2] and  v[1] == v[2] then
                bFindSame = true
                findIndex = i
                break
            end
        end
        print("findIndex--------->",findIndex)

        if bFindSame and findIndex ~= 0 then 
            return sParray[findIndex], sBarray[findIndex]
        else
            return sParray[1], sBarray[1]
        end

    end
end
----------------------------------------------------------------------------
function CDMahjongMJZY:checkIsJiang(arr)
    if TABLE_SIZE(arr) ~= 2 then
        return false
    end

    if arr[1] and arr[2] then
        if arr[1] == arr[2] or arr[1] == self:getMahjongLaiZi() or arr[2] == self:getMahjongLaiZi() then
            return true
        end
    end
    return false
end
----------------------------------------------------------------------------
---isFind 搜索指定对象是否存在
---@param sArray table 牌组
---@param mahjong number 要找的数值
---@return boolean 是否找到
function CDMahjongMJZY:isFind(sArray, mahjong)
    local size = TABLE_SIZE(sArray)
    for i = 1, size do
        if  sArray[i] == mahjong then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
---isFindMahjong 搜索指定对象是否存在会进行红中配转换
---@param sArray table 牌组
---@param mahjong number 要找的数值
---@return number 返回具体用了哪张
function CDMahjongMJZY:isFindMahjong(sArray, mahjong)
    local size = TABLE_SIZE(sArray)
    for i = 1, size do
        if  sArray[i] == mahjong then
            return mahjong
        end
    end
    return 0
end
----------------------------------------------------------------------------
---checkHuPai 检查胡牌（递归处理)
---@param sVecPai table 检查的普通牌组
---@param sVecLai table 检查的赖子牌组
---@param bJiang boolean 是否有将牌
---@param sVecSavePai boolean 以配成的扑牌组
---@param sVecSaveJiang boolean 以配成的将牌组
---@return 是否能胡，牌组, 将牌组
function CDMahjongMJZY:checkHuPai(sVecPai, sVecLai, bJiang, sVecSavePai, sVecSaveJiang)
    if  TABLE_SIZE(sVecPai) == 0 and TABLE_SIZE(sVecLai) == 0 then
        return true
    else
        -- 有红中不能胡牌
        -- 将牌没有的情况下先找将牌
        if  (not bJiang) and TABLE_SIZE(sVecPai) >= 2 and sVecPai[1] == sVecPai[2] then
            --cclog( "checkHuPai ->1<- (%u),(%u)", sVecPai[1], sVecPai[2])
            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            self:push_back(vecDelePai, sVecPai, 1, 2)
            self:push_back(vecNextPai, sVecPai, 3, TABLE_SIZE(sVecPai))
            self:push_back(vecNextLai, sVecLai, 1, TABLE_SIZE(sVecLai))

            self:push_back(sVecSaveJiang, vecDelePai, 1, TABLE_SIZE(vecDelePai))
            if  self:checkHuPai(vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then
                return true
            end
            self:pop_back(sVecSaveJiang, TABLE_SIZE(vecDelePai))
        end

        -- 三张牌组成刻子
        if  TABLE_SIZE(sVecPai) >= 3 and sVecPai[1] and sVecPai[1] == sVecPai[2] and sVecPai[1] == sVecPai[3] then
            --cclog( "checkHuPai ->2<- (%u),(%u),(%u)", sVecPai[1], sVecPai[2], sVecPai[3])
            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back(vecDelePai, sVecPai, 1, 3)
            self:push_back(vecNextPai, sVecPai, 4, TABLE_SIZE(sVecPai))
            self:push_back(vecNextLai, sVecLai, 1, TABLE_SIZE(sVecLai))

            self:push_back(sVecSavePai, vecDelePai, 1, TABLE_SIZE(vecDelePai))
            if  self:checkHuPai(vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then
                return true
            end
            self:pop_back(sVecSavePai, TABLE_SIZE(vecDelePai))
        end

        -- 三张组组成顺子
        if  TABLE_SIZE(sVecPai) >= 3 and sVecPai[1] < 41 then

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

        --=====以上是没有赖子的胡牌算法=====

        -- 一张牌和一个赖子组成将牌
        if  (not bJiang) and TABLE_SIZE(sVecPai) >= 1 and TABLE_SIZE(sVecLai) >= 1 then

            --cclog( "checkHuPai ->4<- (%u),(%u)", sVecPai[1], sVecLai[1])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSaveJiang, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDeleLai))
        end

        -- 两张牌和一个赖子组成刻子
        if  TABLE_SIZE( sVecPai) >= 2 and TABLE_SIZE( sVecLai) >= 1 and sVecPai[1] == sVecPai[2] then

            --cclog( "checkHuPai ->5<- (%u),(%u),(%u)", sVecPai[1], sVecPai[2], sVecLai[1])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 两张牌和一个赖子组成顺子
        if  TABLE_SIZE( sVecPai) >= 2 and 
            TABLE_SIZE( sVecLai) >= 1 and  
            sVecPai[1] < 41 then

            local pai_other1 = self:isFindMahjong( sVecPai, sVecPai[1]+1)
            local pai_other2 = self:isFindMahjong( sVecPai, sVecPai[1]+2)

            if  ((( sVecPai[1]%10 < 9) and pai_other1 ~= 0) or
                 (( sVecPai[1]%10 < 8) and pai_other2 ~= 0)) then

                --cclog( "checkHuPai ->6<- (%u),(%u)/(%u),(%u)", sVecPai[1], pai_other1, pai_other2, sVecLai[1])

                local vecNextPai = {}
                local vecNextLai = {}
                local vecDelePai = {}
                local vecDeleLai = {}

                self:push_back( vecDelePai, sVecPai, 1, 1)
                self:push_back( vecDeleLai, sVecLai, 1, 1)
                self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))

                if  pai_other1 ~= 0 then

                    vecDelePai[ TABLE_SIZE( vecDelePai)+1] = pai_other1
                    if  sVecPai[1]%10 == 8 then

                        sVecSavePai[ TABLE_SIZE( sVecSavePai)] = vecDeleLai[1]
                        sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = sVecPai[1]
                        sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = pai_other1
                    else
                        sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = pai_other1
                        sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = vecDeleLai[1]
                    end
                elseif  pai_other2 ~= 0 then

                    vecDelePai[ TABLE_SIZE( vecDelePai)+1] = pai_other2
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = vecDeleLai[1]
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = pai_other2
                end

                self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
                self:pop_array( vecNextPai, vecDelePai)
                self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

                if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                    return true
                end
                self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
                self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
            end
        end

        -- 一张牌和两个赖子组成的牌
        if  TABLE_SIZE( sVecPai) >= 1 and TABLE_SIZE( sVecLai) >= 2 then

            --cclog( "checkHuPai ->7<- (%u),(%u),(%u)", sVecPai[1], sVecLai[1], sVecLai[2])
            
            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 三张赖子组成的牌
        if  TABLE_SIZE( sVecLai) >= 3 then

            --cclog( "checkHuPai ->8<- (%u),(%u),(%u)", sVecLai[1], sVecLai[2], sVecLai[3])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 3)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 4, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 两张赖子组成将牌
        if  (not bJiang) and TABLE_SIZE( sVecLai) >= 2 then

            --cclog( "checkHuPai ->9<- (%u),(%u)", sVecLai[1], sVecLai[2])

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDeleLai))
        end

        return false
    end
end


-- 检查胡牌（7对子)
-- 参数: 检查的普通牌组,检查的赖子组,储存牌
function CDMahjongMJZY:checkSevenJiang( sVecPai, sVecLai, sVecSavePai)

    if  TABLE_SIZE( sVecPai) == 0 and TABLE_SIZE( sVecLai) == 0 then

        return true
    else

        -- 两张相同牌组成对子
        if  TABLE_SIZE( sVecPai) >= 2 and sVecPai[1] == sVecPai[2] then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end

            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
        end
        -- 一张牌一张赖子组成对子
        if  TABLE_SIZE( sVecPai) >= 1 and TABLE_SIZE( sVecLai) >= 1 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end
        -- 两张赖子组成对子
        if  TABLE_SIZE( sVecLai) >= 2 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        return false
    end
end

---checkAllHuPai 检测所有胡牌 只能检测自摸胡牌
---@param sVecPai table 牌组
---@param sVecLai table 赖子牌组
---@param bJiang boolean 是否有将牌
---@return 是否能胡，牌组, 将牌组
function CDMahjongMJZY:checkAllHuPai(sVecPai, sVecLai, bJiang)
    local savePai = {}   
    local saveJiang = {}
    --七对
    if  TABLE_SIZE(sVecPai) + TABLE_SIZE(sVecLai) ==14 or bJiang then
        if  self:checkSevenJiang(sVecPai,sVecLai,savePai) then
            return true,savePai,saveJiang
        end
        savePai = {}
        saveJiang = {}
    end

    if  self:checkHuPai(sVecPai, sVecLai, bJiang, savePai, saveJiang) then
        return true, savePai, saveJiang
    end
    return false
end

----------------------------------------------------------------------------
---canHuPai 判断是否胡牌
---@param v_mahjongs table 用于检查的有效并且排序（从小到大）过的牌组(mahjong))
---@return 是否能胡，胡牌组
function CDMahjongMJZY:canHuPai( v_mahjongs)
    local sVecPai, sVecLai = self:getArray_Pai_Lai(v_mahjongs)

    local isHu, sVecHuPai, sVecJiang = self:checkAllHuPai(sVecPai, sVecLai, false)
    if  isHu then
        self:push_back(sVecHuPai, sVecJiang, 1, TABLE_SIZE(sVecJiang))
        return true, sVecHuPai
    end
    return false
end

----------------------------------------------------------------------------
-- 判断是否胡牌
-- 参数: 用于检查的有效并且排序（从小到大）过的牌组(mahjong))
---canHuPai_def 判断是否胡牌
---@param mahjongs table 检测胡牌牌组
---@return 是否能胡，胡牌组
function CDMahjongMJZY:canHuPai_def(mahjongs)
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai(mahjongs)
    local isHu, sVecHuPai, sVecJiang = self:checkAllHuPai(sVecPai, sVecLai, false)

    if  isHu then
        self:push_back(sVecHuPai, sVecJiang, 1, TABLE_SIZE(sVecJiang))
        return true, sVecHuPai
    end
    return false
end

---canHuPai_defEX 会去除杠的牌,判断能否胡牌(递归方式)
---@param mahjongs table 检测胡牌的牌组
---@return 是否能胡，胡牌组
function CDMahjongMJZY:canHuPai_defEX(mahjongs)
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai(mahjongs)
    local isHu, sVecHuPai, sVecJiang = self:checkAllHuPai(sVecPai, sVecLai, false)

    if  isHu then
        self:push_back(sVecHuPai, sVecJiang, 1, TABLE_SIZE(sVecJiang))
        return true, sVecHuPai
    end
    return false
end

----------------------------------------------------------------------------
---canHuPai_WithOther 判断是否胡牌根据自己的有效牌组＋别人打的一张牌 (检测自己听哪一张牌)
---@param v_mahjongs table 用于判断听牌的牌组
---@param mahjong number 别人打的牌
---@return 是否能听，牌组，将牌
function CDMahjongMJZY:canHuPai_WithOther(v_mahjongs, mahjong)
    local sVecPai, sVecLai = self:getArray_Pai_Lai(v_mahjongs)
    if  mahjong ~= self.m_nMahjongLaiZi then
        sVecPai[ TABLE_SIZE(sVecPai) + 1] = mahjong
        self:defMahjongSort_stb(sVecPai)
    else
        self:push_mahjong(sVecLai, mahjong)
    end

    local isHu, sVecHuPai, sVecJiang = self:checkAllHuPai(sVecPai, sVecLai, false)

    if  isHu then
        self:push_back(sVecHuPai, sVecJiang, 1, TABLE_SIZE(sVecJiang))
        return true, sVecHuPai
    end
    return false
end

----------------------------------------------------------------------------
---canTingPai 判断是否听牌 (显示听标记)
---@param v_mahjongs table 用于判断听牌的牌组
---@param mahjong number 剔除的牌
---@return 是否能听，牌组，将牌
function CDMahjongMJZY:canTingPai(v_mahjongs, mahjong)

    -- 分开牌组与赖子后默认添加一张赖子来判断是否胡牌
    local sVecPai, sVecLai = self:getArray_Pai_Lai(v_mahjongs)
    self:push_mahjong(sVecLai, self:getMahjongLaiZi())
    if  mahjong == self.m_nMahjongLaiZi then
        self:pop_mahjong(sVecLai, mahjong)
    else
        self:pop_mahjong(sVecPai, mahjong)
    end

    return self:checkAllHuPai(sVecPai, sVecLai, false)
end

---canTingPaiEX 结算界面听牌显示
---@param mahjongs table 用于判断听牌的牌组
---@return 是否能听，牌组，将牌
function CDMahjongMJZY:canTingPaiEX(mahjongs)
    local sVecPai, sVecLai = self:getArray_Pai_Lai_ex(mahjongs)
    self:push_mahjong(sVecLai, self:getMahjongLaiZi())

    return self:checkAllHuPai(sVecPai, sVecLai, false)
end

----------------------------------------------------------------------------
---canGangPai_withAll 判断是否杠牌(遍历所有的牌)
---@v_mahjongs table 手牌
---@s_mahjongs table 摊开的牌组 
---@f_mahjongs table 以前放弃的杠牌(没有则传空)
---@b_mahjongs table 最后摸得牌
---@return boolean, table 是否可以杠牌， 杠牌组
function CDMahjongMJZY:canGangPai_withAll(v_mahjongs, s_mahjongs, f_mahjongs, b_mahjongs)
    local v_size = TABLE_SIZE(v_mahjongs)
    local s_size = TABLE_SIZE(s_mahjongs)

    local v_array = {}
    for i = 1, v_size do
        v_array[i] = v_mahjongs[i].mahjong
    end

    local s_array = {}
    for i = 1, s_size do
        s_array[i] = s_mahjongs[i].mahjong
    end
    print("=========canGangPai_withAll-============")
    dumpArray(s_array)
   
    if  f_mahjongs ~= nil then
        self:pop_allMahjong(v_array, f_mahjongs)
        v_size = TABLE_SIZE(v_array)
    end

    if  b_mahjongs ~= nil then
        self:pop_allMahjong(v_array, b_mahjongs)
        v_size = TABLE_SIZE(v_array)
    end

    local array = {}
    local index = 1
    local gang_size = 4
    for i = 1, v_size do
        local mahjong = v_array[i]
        if mahjong ~= self:getMahjongLaiZi() then
            index = 1
            array[index] = mahjong
            for j = i + 1, v_size do
                if  v_array[j] == mahjong then
                    array[ index] = mahjong
                    index = index + 1
                    if  index >= gang_size then
                        return true, array
                    end
                else
                    break
                end
            end

            for j = 1, s_size - 2 do
                if  self:isThreeSame(s_array[j],s_array[j + 1]) and 
                    self:isThreeSame(s_array[j + 1], s_array[j + 2]) then
                    if  s_array[j] == mahjong then
                        index = 4
                        if  index >= gang_size then
                            return true, array
                        end
                    end
                end
            end
        end
    end
    return false, array
end

---canAnGang 安否暗杠
---@param handCards table 手牌
---@param gValue number 摸到的牌
---@return boolean 能否暗杠
function CDMahjongMJZY:canAnGang(handCards, gValue)
    local curHandCards = self:getValueFromArr(handCards)
    local curNum = 0
    for i,v in ipairs(curHandCards) do
        if  v ~= self.m_nMahjongLaiZi and v < 40 then
            if  v == gValue then
                curNum = curNum + 1
            end
        end
    end

    if  curNum >= 4 then
        return true
    end

    return false
end

---canAnGangWithReconnect 断线重连上来能否杠牌
---@param handCards 手牌
---@return boolean, table 是否可以杠，能杠则返回杠牌组
function CDMahjongMJZY:canAnGangWithReconnect(handCards)
    local curHandCards = self:getValueFromArr(handCards)
    local gangArr = {}
    local curMahjong = 0
    local curNum = 0
    for i,v in ipairs(curHandCards) do
        if  v ~=curMahjong then
            curMahjong = v
            curNum = 1
        else
            curNum = curNum + 1
            if  curNum >= 4 then
                self:push_mahjong(gangArr, curMahjong)
            end
        end
    end
    if  TABLE_SIZE(gangArr) > 0 and self:mahjongTotal_get() > 0 then
        return true, gangArr
    end
    return false
end

---isThreeSame 判断两两比较是否相同
---@param value_1 number 第一个比对的牌
---@param value_2 number 第二个比对的牌
---@return boolean 是否一样
function CDMahjongMJZY:isThreeSame(value_1, value_2)
    if value_1 and value_2 then 
        if value_1 == value_2 then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
---canChi 能否吃牌
---@param handCards table 手牌
---@param mahjong number 上家打出的牌
---@return boolean, table 是否能吃，且能吃则返回匹配数组
function CDMahjongMJZY:canChi(handCards, mahjong)
    local curHandCards = self:getValueFromArr(handCards)
    local handpai, handlai = self:getArrayDef_Pai_Lai(curHandCards)

    local isChi = false
    local handsize = TABLE_SIZE(handpai)
    local pai_alone = {}
    local matchTable = {}
    for i = 1, handsize do
        -- 风牌和箭牌 与 赖子 不在吃牌的判断中
        if  handpai[i] < 40 and self.m_nMahjongLaiZi ~= handpai[i] then
            local sameNum = 0
            for j,k in ipairs(pai_alone) do
                if  handpai[i] == k then
                    sameNum = 1    
                    break
                end
            end
            if  sameNum == 0 then
                local newTableSize = TABLE_SIZE(pai_alone)
                pai_alone[newTableSize + 1] = handpai[i]
            end
        end
    end
    --去掉手中的重复牌并保存在pai_alone 
    local alonesize = TABLE_SIZE(pai_alone)
    for i=1,alonesize do
        if math.ceil(pai_alone[i] / 10) == math.ceil(mahjong / 10) then
            local matchSize = TABLE_SIZE(matchTable)
            local needpai = nil
            if  pai_alone[i] == mahjong - 2 then 
                for j,k in ipairs(pai_alone) do
                    if k == mahjong - 1 then
                        needpai = k
                        break
                    end
                end
                if needpai then
                    matchTable[matchSize + 1] = {pai_alone[i], needpai, mahjong}
                    self:defMahjongSort_stb(matchTable[matchSize + 1])
                    isChi = true
                end
            end
            if  pai_alone[i] == mahjong - 1 then 
                for j,k in ipairs(pai_alone) do
                    if k == mahjong + 1 then
                        needpai = k
                        break
                    end
                end
                if needpai then
                    matchTable[matchSize + 1] = {pai_alone[i],mahjong,needpai}
                    self:defMahjongSort_stb(matchTable[matchSize + 1])
                    isChi = true
                end
            end
            if  pai_alone[i] == mahjong + 1 then 
                for j,k in ipairs(pai_alone) do
                    if k == mahjong + 2 then
                        needpai = k
                        break
                    end
                end
                if needpai then
                    matchTable[matchSize + 1] = {mahjong,pai_alone[i], needpai}
                    self:defMahjongSort_stb(matchTable[matchSize + 1])
                    isChi = true
                end
            end
        end
        
    end

    return isChi, matchTable
end

---getOwnArrFromArr 把吃牌组剔除吃掉的牌，返回自己原有的牌组
---@param arr table 吃过牌的牌组
---@param mahjong number 吃的牌
---@return table 返回处理好的原有数组
function CDMahjongMJZY:getOwnArrFromArr(arr, mahjong)
    local curArr = {}
    if arr and mahjong then
        for i,v in ipairs (arr) do
            curArr[TABLE_SIZE(curArr) + 1] = v
        end

        for i,v in ipairs(curArr) do
            if v == mahjong then
                table.remove(curArr, i)
                break
            end
        end
        return curArr
    end
    return curArr
end

---getPaiFromArr 把要吃的牌单个返回
---@param arr table 要返回单张的吃牌组
---@return number, number 牌1，牌2
function CDMahjongMJZY:getPaiFromArr(arr)
    if  type(arr) == "table" and TABLE_SIZE(arr) > 1 then
        return arr[1], arr[2]
    end
end

----------------------------------------------------------------------------
---checkD 检测对
---param outGroup table 摊牌组
---@return table 返回匹配数组
function CDMahjongMJZY:checkD(outGroup)
    local matchArr = {}
    if  outGroup and TABLE_SIZE(outGroup)>0 then
        for i,v in ipairs(outGroup) do
            if  v.type_op == DEF_MJZY_PENG then
                matchArr[TABLE_SIZE(matchArr)+1] = v.mahjongs[1]
            end
        end
    end
    return matchArr
end

---canGangAfterPeng 碰完之后判断是否可以杠
---@param hadPai table 手牌
---@param isPeng boolean 是否碰过
---@param outGroup table 摊牌组
---@return boolean, table, number 返回是否可以杠，匹配的杠牌数组, 最后一次的碰牌
function CDMahjongMJZY:canGangAfterPeng(hadPai, isPeng, outGroup)
    local curHandCards = self:getValueFromArr(hadPai)
    local handpai,handLai = self:getArrayDef_Pai_Lai( curHandCards)

    local gangPai = {}
    local canGang = false
    local outPeng = self:checkD(outGroup)
    local lastPengMahjong = 0

    if  isPeng then
        if  outGroup[TABLE_SIZE(outGroup)].type_op == DEF_MJZY_PENG then
            lastPengMahjong = outGroup[TABLE_SIZE(outGroup)].mahjongs[1]
        end
    end

    if TABLE_SIZE(outPeng) > 0 and self:mahjongTotal_get() > 0 then
        for i,v in ipairs(handpai) do
            for j,k in ipairs(outPeng) do
                if v == k then
                    gangPai[TABLE_SIZE(gangPai) + 1] = v
                    canGang = true
                end
            end
        end
    end

    return canGang, gangPai, lastPengMahjong
end

---FindGangIndex 能否找到杠牌的索引
---@param arr table 数组
---@param value 需要找寻的杠牌的数值
---@return boolean 能否找到该索引
function CDMahjongMJZY:FindGangIndex(arr, value)
    if  arr and  TABLE_SIZE(arr) > 0 then
        local findIndex = 0
        for i,v in ipairs(arr) do
            if  v == value then
                findIndex = findIndex + 1
            end
        end
        if  findIndex >= 4 then
            return true
        end
    end
    return false
end

---canPengWithReconnect 断线重连后能否碰牌
---@param hadPai table 手牌
---@return boolean, table 能否碰，碰牌组
function CDMahjongMJZY:canPengWithReconnect(hadPai)
    local curHandCards = self:getValueFromArr(hadPai)
    local handpai, handLai = self:getArrayDef_Pai_Lai(curHandCards)
    local canPeng = false
    local pengPai = {}
    if  TABLE_SIZE(handpai) > 4 then
        self:defMahjongSort_stb(handpai)
        local curMahjong = 0
        for i,v in ipairs(handpai) do
            if  v ~= curMahjong then
                curMahjong = v
                if  self:FindGangIndex(handpai, v) then
                    pengPai[TABLE_SIZE(pengPai) + 1] = v
                    canPeng = true
                end
            end
        end
    end
    return canPeng, pengPai
end

----------------------------------------------------------------------------
---canZhuoPao 能否捉炮
---@param myHandCards table 自己的手牌
---@param mahjong table 别人打出的牌
---@return boolean, table, table 能否捉炮胡，能胡则返回 牌组 和 将牌组
function CDMahjongMJZY:canZhuoPao(myHandCards, mahjong)
    local curMahArr = self:getValueFromArr(myHandCards)
  
    self:push_mahjong(curMahArr, mahjong)
    self:defMahjongSort_stb(curMahArr)

  
    local tmpPai, tmpLai = self:getArrayDef_Pai_Lai(curMahArr)
    return self:checkAllHuPai(tmpPai, tmpLai, false)
end

---getValueFromGroup 从摊牌组中取出摊牌数字
---@param cards 需要提取的摊牌数组
---@return table 返回取出的数字组
function CDMahjongMJZY:getValueFromGroup(cards)
    local arr = {}
    if  cards and TABLE_SIZE(cards) > 0 then
        for i,v in ipairs(cards) do
            for j,k in ipairs(v.mahjongs) do
                arr[TABLE_SIZE(arr) + 1] = k
            end
        end
    end
    return arr
end

---getValueFromArr 从数组中获取牌的数字
---@param cards table 需要提取的牌的数组
---@return table 返回取出的数字组
function CDMahjongMJZY:getValueFromArr(cards)
    local arr = {}
    if  cards and TABLE_SIZE(cards) > 0 then
        for  i,v in ipairs(cards) do
            if  type(v) == "table" then
                arr[TABLE_SIZE(arr) + 1] = v.mahjong
            else
                arr[TABLE_SIZE(arr) + 1] = v
            end
        end
    end
    return arr
end

---sortByYH 硬胡的排序
---@param cards handCards 需要排序的牌组
---@return table 返回排序好的牌组
function CDMahjongMJZY:sortByYH( handCards )
    local curHandCards = {}
    self:push_back(curHandCards,handCards,1,TABLE_SIZE(handCards))

    local curLai = {}
    local isHu,sVecHuPai,sVecJiang = self:checkAllHuPai(curHandCards,curLai,false)

    if  isHu then
        self:push_back(sVecHuPai,sVecJiang,1,TABLE_SIZE(sVecJiang))
        return sVecHuPai
    end
    return handCards
end

----------------------------------------------------------------------------
-- 创建江陵晃晃数学库
function CDMahjongMJZY.create()
    cclog("CDMahjongMJZY.create")
    local   instance = CDMahjongMJZY.new()
    return  instance
end