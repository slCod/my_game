--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongMJZY_AI 湖北江陵晃晃麻将AI库
//File Name:    mahjong_MJZY_ai.h
//Author:       GostYe
//Start Data:   2018.05.15
//Language:     XCode 9.3
//Target:       IOS, Android
/****************************************************************************
-- 使用：（创建对象后）
    1). addMahjong_FromMath     给AI对象添加牌（参数从前还是从后发牌)
    2). sortAllVMahjongs        发完牌后调用，用于从小到大排序
    3). outMahjong_WithSelf     思考自己要出什么牌
    4). outMahjong_WithOther    根据别人出的牌思考操作（碰、杠、胡、出牌)
]]

require( REQUIRE_PATH.."mahjong_define")
require( "mahjong_mjzy.mahjong_mjzy_math")
local casinoclient = require("script.client.casinoclient")

CDMahjongMJZY_AI = class("CDMahjongMJZY_AI")
CDMahjongMJZY_AI.__index = CDMahjongMJZY_AI

CDMahjongMJZY_AI.m_sVMahjongs = nil      -- 手上有效牌
CDMahjongMJZY_AI.m_sSMahjongs = nil      -- 摊开的牌
CDMahjongMJZY_AI.m_sIMahjongs = nil      -- 所有无效牌（自己打出的，以及摊开的牌)

CDMahjongMJZY_AI.m_sNMahjongs = nil      -- 新摊牌数据（按照组分配）
CDMahjongMJZY_AI.m_sForgoGang = nil      -- 自己没有杠的牌
CDMahjongMJZY_AI.m_sForgoPeng = nil      -- 放弃的碰牌
CDMahjongMJZY_AI.m_sForgoChi  = nil      -- 放弃吃的牌
CDMahjongMJZY_AI.m_sFangFMahjongs = nil    -- 放风牌组
CDMahjongMJZY_AI.m_sPaoFMahjongs = nil    -- 跑风牌组

CDMahjongMJZY_AI.m_bNotCatch = false     -- 不能捉铳

CDMahjongMJZY_AI.gangTimes = 0           -- 杠的次数
CDMahjongMJZY_AI.gangMatchTimes = 0      -- 是否更新杠的次数
CDMahjongMJZY_AI.m_pGangKai = false      -- 是否杠后开花
CDMahjongMJZY_AI.m_sOutCards = nil       -- 打出去的牌

DEF_MJZY_OP_PENG   = 1                   -- 碰
DEF_MJZY_OP_GANG_M = 2                   -- 明杠
DEF_MJZY_OP_GANG_A = 3                   -- 暗杠
DEF_MJZY_OP_GANG_B = 4                   -- 补杠
DEF_MJZY_OP_CHI    = 5                   -- 吃

----------------------------------------------------------------------------
-- 构造函数
function CDMahjongMJZY_AI:ctor()
    cclog("CDMahjongMJZY_AI::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义

----------------------------------------------------------------------------
-- 初始化
function CDMahjongMJZY_AI:init()
    cclog("CDMahjongMJZY_AI:init")
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongMJZY_AI:release()
    cclog("CDMahjongMJZY_AI:release")
    self:clearAllMahjongs()
end

----------------------------------------------------------------------------
-- 设置/获取AI对象类型(参考22行定义)
function CDMahjongMJZY_AI:setType( type)
    self.m_nType = type
end
function CDMahjongMJZY_AI:getType()
    return self.m_nType
end

----------------------------------------------------------------------------
-- 清理牌
function CDMahjongMJZY_AI:clearAllMahjongs()
    self.m_sVMahjongs = {}
    self.m_sSMahjongs = {}
    self.m_sIMahjongs = {}

    self.m_sFangFMahjongs = {}
    self.m_sPaoFMahjongs  = {}

    self.m_sNMahjongs = {}
    self.m_sForgoGang = {}
    self.m_sForgoPeng = {}
    self.m_sForgoChi  = {}
    self.m_nChiGroup  = {}           -- 摊派吃的标记
    self.m_sOutCards  = {}
end

----------------------------------------------------------------------------
-- 添加麻将(发牌调用)
-- 参数: mahjong_MJZY_math类对象，从前取还是从后取
function CDMahjongMJZY_AI:addMahjong_FromMath(mahjong_MJZY, forward)

    if  not forward then
        forward = true
    end
    
    if  self.m_sVMahjongs == nil then
        self.m_sVMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sVMahjongs)+1

    self.m_sVMahjongs[index] = {}
    self.m_sVMahjongs[index].mahjong = mahjong_MJZY:getMahjong( forward)
    self.m_sVMahjongs[index].index = index
    return self.m_sVMahjongs[index].mahjong
end

---------------------------------------------------------------
--添加放风牌组
-- 参数: 需要添加的牌组---------------
function CDMahjongMJZY_AI:addFangFMahjong( mahjongs)

    if  self.m_sFangFMahjongs == nil then
        self.m_sFangFMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sFangFMahjongs)+1
    local size  = TABLE_SIZE( mahjongs)

    for i = 1, size do

        self.m_sFangFMahjongs[index] = mahjongs[i]
        index = index + 1
    end
end
function CDMahjongMJZY_AI:getFangFMahjong()
    if  self.m_sFangFMahjongs == nil then
        self.m_sFangFMahjongs = {}
    end
    return self.m_sFangFMahjongs
end
function CDMahjongMJZY_AI:getFangFMahjongSize()
    if  self.m_sFangFMahjongs == nil then
        self.m_sFangFMahjongs = {}
    end
    return TABLE_SIZE( self.m_sFangFMahjongs)
end

function CDMahjongMJZY_AI:getFangFMahjongWithIndex( i)
    return self.m_sFangFMahjongs[i]
end
----------------------------------------------------------------------------
--- 添加跑风牌组
-- 参数: 需要添加的牌组---------------
function CDMahjongMJZY_AI:addPaoFMahjong( mahjong)

    if  self.m_sPaoFMahjongs == nil then
        self.m_sPaoFMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sPaoFMahjongs)+1
    self.m_sPaoFMahjongs[index] = mahjong 
end

function CDMahjongMJZY_AI:getPaoFMahjong()
    if  self.m_sPaoFMahjongs == nil then
        self.m_sPaoFMahjongs = {}
    end
    return self.m_sPaoFMahjongs
end
function CDMahjongMJZY_AI:getPaoFMahjongSize()
    if  self.m_sPaoFMahjongs == nil then
        self.m_sPaoFMahjongs = {}
    end
    return TABLE_SIZE( self.m_sPaoFMahjongs)
end

function CDMahjongMJZY_AI:getPaoFMahjongWithIndex( i)
    return self.m_sPaoFMahjongs[i]
end

----------------------------------------------------------------------------
-- 将牌添加到有效牌中
-- 参数: 需要添加的牌组
function CDMahjongMJZY_AI:addVMahjong( mahjong)

    if  self.m_sVMahjongs == nil then
        self.m_sVMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sVMahjongs)+1

    self.m_sVMahjongs[index] = {}
    self.m_sVMahjongs[index].mahjong = mahjong
    self.m_sVMahjongs[index].index = index
    return self.m_sVMahjongs[index].mahjong
end

----------------------------------------------------------------------------
-- 将牌组添加到有效牌中
-- 参数: 需要添加的牌组
function CDMahjongMJZY_AI:addVMahjong_withArray( mahjongs)

    if  self.m_sVMahjongs == nil then
        self.m_sVMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sVMahjongs)+1
    local size = TABLE_SIZE( mahjongs)

    for i = 1, size do 

        self.m_sVMahjongs[index] = {}
        self.m_sVMahjongs[index].mahjong = mahjongs[i]
        self.m_sVMahjongs[index].index = index

        index = index + 1
    end
end

----------------------------------------------------------------------------
-- 将牌组添加到摊牌组中
-- 参数: 需要添加的牌组
function CDMahjongMJZY_AI:addSMahjong( mahjongs)

    if  self.m_sSMahjongs == nil then
        self.m_sSMahjongs = {}
    end

    local index = TABLE_SIZE( self.m_sSMahjongs)+1
    local size  = TABLE_SIZE( mahjongs)

    for i = 1, size do
        self.m_sSMahjongs[index] = {}
        self.m_sSMahjongs[index].mahjong = mahjongs[i]
        self.m_sSMahjongs[index].index = index

        index = index + 1
    end
end

----------------------------------------------------------------------------
-- 将牌组添加到新摊牌组中
-- 参数: 需要添加的牌组, 索引, OP类型
function CDMahjongMJZY_AI:addNMahjong( mahjongs, tag_idx, op,idx,catchCard)

    local size = TABLE_SIZE( mahjongs)

    if  size <= 0 then
        return
    end
    
    local index = 0
    if  self.m_sNMahjongs == nil then
        self.m_sNMahjongs = {}
    end
    
    -- 假如是补杠，那么判断哪组碰牌里面的牌和补的相同，如果相同那么插入杠信息
    -- 否则添加一组新的摊牌组
    if  op == DEF_MJZY_OP_GANG_B or op == 0 then

        size = TABLE_SIZE( self.m_sNMahjongs)

        for i = 1, size do

            if  self.m_sNMahjongs[i].type_op == DEF_MJZY_OP_PENG and 
                self.m_sNMahjongs[i].mahjongs[1] == mahjongs[1] then

                index = TABLE_SIZE( self.m_sNMahjongs[i].mahjongs)+1
                self.m_sNMahjongs[i].mahjongs[index] = mahjongs[1]
                self.m_sNMahjongs[i].tag_idx = idx
                self.m_sNMahjongs[i].type_op = DEF_MJZY_OP_GANG_B
                return
            end
        end

    else

        size = TABLE_SIZE( mahjongs)
        index = TABLE_SIZE( self.m_sNMahjongs)+1
        self.m_sNMahjongs[index] = {}
        self.m_sNMahjongs[index].tag_idx = tag_idx
        self.m_sNMahjongs[index].type_op = op
        self.m_sNMahjongs[index].type_index = index
        self.m_sNMahjongs[index].mahjongs = {}
        if  catchCard then
            self.m_sNMahjongs[index].target_card = catchCard
        end
        for i = 1, size do
            self.m_sNMahjongs[index].mahjongs[i] = mahjongs[i]
        end
    end
    
end
----------------------------------------------------------------------------
-- 用于断线重连 根据摊牌绘制牌
-- 把摊派组按顺序提取出来返回出去
function CDMahjongMJZY_AI:drawByOutPai(  )
    local detailArr = {}
    for i,v in ipairs(self.m_sNMahjongs) do
        for j,k in ipairs(v.mahjongs) do
            detailArr[TABLE_SIZE(detailArr)+1] = k
        end
    end
    return detailArr
end

----------------------------------------------------------------------------
-- 获取摊牌组
function CDMahjongMJZY_AI:getNMahjong()
    if  self.m_sNMahjongs == nil then
        self.m_sNMahjongs = {}
    end

    return self.m_sNMahjongs
end

----------------------------------------------------------------------------
-- 获取摊牌组总数
function CDMahjongMJZY_AI:getNMahjongSize()
    return TABLE_SIZE(self.m_sNMahjongs)
end

----------------------------------------------------------------------------
-- 获取摊牌组根据索引
function CDMahjongMJZY_AI:getNMahjongWithIndex( index)

    if  index <= 0 or index > self:getNMahjongSize() then
        return nil
    end
    return self.m_sNMahjongs[index]
end

----------------------------------------------------------------------------
-- 搜索摊牌组根据指定的麻将
function CDMahjongMJZY_AI:getNMahjongWithMahjong( mahjong,index)

    local curIndex = self:getOutPai(index)

    if  curIndex and self.m_sNMahjongs[curIndex] then
        return self.m_sNMahjongs[curIndex]
    end
    return nil
end

function CDMahjongMJZY_AI:getOutPai( index )
    local curSize = 0
    for i ,v in ipairs(self.m_sNMahjongs) do
        local childSize = TABLE_SIZE(v.mahjongs)
        curSize = curSize + childSize
        if curSize>= index then
            return i
        end
    end
    return nil
end

----------------------------------------------------------------------------
-- 或去OP组的类型，根据我要检查的牌
-- 参数: 要检查的牌
function CDMahjongMJZY_AI:getNTypeWithMahjong( mahjong)

    local size = TABLE_SIZE( self.m_sNMahjongs)
    for i = 1, size do

        if  TABLE_SIZE( self.m_sNMahjongs[i].mahjongs) > 0 and
            self.m_sNMahjongs[i].mahjongs[1] == mahjong then

            return self.m_sNMahjongs[i].type_op
        end
    end
    return 0
end
----------------------------------------------------------------------------
-- 搜索摊牌组根据指定的麻将
function CDMahjongMJZY_AI:getNMahjongTypeWithMahjong( mahjong)

    local size = self:getNMahjongSize()
    for i = 1, size do

        if  mahjong == self.m_sNMahjongs[i].mahjongs[1] then
            return self.m_sNMahjongs[i]
        end
    end
    return nil
end
----------------------------------------------------------------------------
-- 添加无效牌(打出的牌＋摊开的牌)
-- 参数: 牌面值
function CDMahjongMJZY_AI:addIMahjong( mahjong)
    -- print("打出的牌----->",mahjong)

    if  self.m_sIMahjongs == nil then
        self.m_sIMahjongs = {}
    end

    self.m_sIMahjongs[ TABLE_SIZE(self.m_sIMahjongs)+1] = mahjong
end

----------------------------------------------------------------------------
-- 删除麻将在有效牌组中(可在打出牌后调用)
-- 会将删除的数值添加到无效牌组中
-- 参数: 牌数值
function CDMahjongMJZY_AI:delVMahjong( mahjong)

    local size = TABLE_SIZE( self.m_sVMahjongs)

    for i = 1, size do

        if  self.m_sVMahjongs[i].mahjong == mahjong then
            -- self:addIMahjong( mahjong) 放到实际代码中去调用
            table.remove( self.m_sVMahjongs, i)
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 删除麻将在有效牌组中(可在打出牌后调用)
-- 会将删除的数值添加到无效牌组中
-- 参数: 索引
function CDMahjongMJZY_AI:delVMahjongWithIndex( index)

    local size = TABLE_SIZE( self.m_sVMahjongs)
    if  index <= size then
        -- self:addIMahjong( self.m_sVMahjongs[index].mahjong) 放到实际代码中去调用
        table.remove( self.m_sVMahjongs, index)
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- 删除所有有效牌组
function CDMahjongMJZY_AI:delAllVMahjong()
    self.m_sVMahjongs = {}
end

----------------------------------------------------------------------------
-- 删除指定牌组(碰，杠后调用)  吃
-- 会将删除的数值添加到无效牌组中
-- 参数: 牌组
function CDMahjongMJZY_AI:delVMahjongs( mahjongs)

    local size = TABLE_SIZE( mahjongs)
    for i = 1, size do

        v_size = TABLE_SIZE( self.m_sVMahjongs)
        for j = 1, v_size do

            if  self.m_sVMahjongs[j].mahjong == mahjongs[i] then
                -- self:addIMahjong( mahjongs[i]) 放到实际代码中去调用
                table.remove( self.m_sVMahjongs, j)
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- 获取有效牌组中的指定牌
-- 参数: 第几张牌
-- 返回: 牌数值
function CDMahjongMJZY_AI:getVMahjong( index)

    if  self.m_sVMahjongs == nil then
        return 0
    else
        if  index > TABLE_SIZE( self.m_sVMahjongs) then
            return 0
        end
        return self.m_sVMahjongs[index].mahjong
    end
end

----------------------------------------------------------------------------
-- 获取摊牌中的指定牌
-- 参数: 第几张牌
-- 返回: 牌数值
function CDMahjongMJZY_AI:getSMahjong( index)

    if  self.m_sSMahjongs == nil then
        return 0
    else
        return self.m_sSMahjongs[index].mahjong
    end
end

----------------------------------------------------------------------------
-- 获取有效牌组总牌数
-- 返回: 牌总数
function CDMahjongMJZY_AI:getVMahjongsSize()

    if  self.m_sVMahjongs == nil then
        return 0
    else
        return TABLE_SIZE( self.m_sVMahjongs)
    end
end

----------------------------------------------------------------------------
-- 获取摊牌组总牌数
-- 返回: 牌总数
function CDMahjongMJZY_AI:getSMahjongsSize()

    if  self.m_sSMahjongs == nil then
        return 0
    else
        return TABLE_SIZE( self.m_sSMahjongs)
    end
end

----------------------------------------------------------------------------
-- 获取所有牌总数
-- 返回: 牌总数
function CDMahjongMJZY_AI:getMahjongsSize()

    return (self:getVMahjongsSize() + self:getSMahjongsSize())
end

function CDMahjongMJZY_AI:reportCanGang( array )
    if  array and TABLE_SIZE(array)>0 then
        local mahjong = array[1]
        for i,v in ipairs(self.m_sVMahjongs) do
            if  v.mahjong == mahjong then
                self:addForgoGang(mahjong)
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- 添加获取放弃杠的牌
function CDMahjongMJZY_AI:addForgoGang( mahjong)

    if  self.m_sForgoGang == nil then
        self.m_sForgoGang = {}
    end

    local size = TABLE_SIZE( self.m_sForgoGang)
    for i = 1, size do

        if  self.m_sForgoGang[i] == mahjong then
            return
        end
    end 
    
    self.m_sForgoGang[ size+1] = mahjong
end
function CDMahjongMJZY_AI:getForgoGang()
    return self.m_sForgoGang
end

----------------------------------------------------------------------------
-- 删除指定的弃杠牌
function CDMahjongMJZY_AI:delForgoGang( mahjong)

    local size = TABLE_SIZE( self.m_sForgoGang)

    for i = 1, size do

        if  self.m_sForgoGang[i] == mahjong then
            table.remove( self.m_sForgoGang, i)
            return
        end
    end
end

----------------------------------------------------------------------------
-- 清除所有放弃的杠牌组
function CDMahjongMJZY_AI:delAllForgoGang()
    self.m_sForgoGang = {}
end

----------------------------------------------------------------------------
-- 添加放弃的碰牌组
function CDMahjongMJZY_AI:addForgoPeng( mahjong)
    -- print("弃碰的麻将----->",mahjong)
    if  self.m_sForgoPeng == nil then
        self.m_sForgoPeng = {}
    end

    local size = TABLE_SIZE( self.m_sForgoPeng)
    for i = 1, size do

        if  self.m_sForgoPeng[i] == mahjong then
            return
        end
    end 
    
    self.m_sForgoPeng[ size+1] = mahjong
end

----------------------------------------------------------------------------
-- 获取放弃的碰牌组
function CDMahjongMJZY_AI:getForgoPeng()
    return self.m_sForgoPeng
end

----------------------------------------------------------------------------
-- 清除所有放弃的碰牌组
function CDMahjongMJZY_AI:delAllForgoPeng()
    self.m_sForgoPeng = {}
end

----------------------------------------------------------------------------
-- 判断指定牌是否在于放弃杠牌中
function CDMahjongMJZY_AI:isInForgoGang( mahjong)

    local size = TABLE_SIZE( self.m_sForgoGang)
    for i = 1, size do

        if  self.m_sForgoGang[i] == mahjong then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 判断指定牌是否在于放弃碰牌中
function CDMahjongMJZY_AI:isInForgoPeng( mahjong)

    local size = TABLE_SIZE( self.m_sForgoPeng)
    for i = 1, size do 
        -- print("self.m_sForgoPeng[i]----->",self.m_sForgoPeng[i])
        if  self.m_sForgoPeng[i] == mahjong then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 添加放弃的吃牌组
function CDMahjongMJZY_AI:addForgoChi( mahjong )
    if not self.m_sForgoChi then
        self.m_sForgoChi = {}
    end

    local size = TABLE_SIZE( self.m_sForgoChi)
    for i = 1, size do

        if  self.m_sForgoChi[i] == mahjong then
            return
        end
    end 
    
    self.m_sForgoChi[ size+1] = mahjong
end

-- 判断指定牌是否在于放弃吃牌中
function CDMahjongMJZY_AI:isInForgoChi( mahjong)

    local size = TABLE_SIZE( self.m_sForgoChi)
    for i = 1, size do 

        if  self.m_sForgoChi[i] == mahjong then
            return true
        end
    end
    return false
end

-- 获取放弃的吃牌组
function CDMahjongMJZY_AI:getForgoChi()
    return self.m_sForgoChi
end

-- 清除所有放弃的吃牌组
function CDMahjongMJZY_AI:delAllForgoChi()
    self.m_sForgoChi = {}
end
----------------------------------------------------------------------------
-- 整理有效牌组(在发牌完成以后调用)
-- 参数: mahjong_MJZY_math类对象
function CDMahjongMJZY_AI:sortAllVMahjongs( mahjong_MJZY)

    if  self.m_sVMahjongs == nil then
        return false
    end
    -- 由小到大的排列
    mahjong_MJZY:mahjongSort_stb( self.m_sVMahjongs)
    return true
end

----------------------------------------------------------------------------
-- 整理摊牌按小到大排列
-- 参数: mahjong_MJZY_math类对象
function CDMahjongMJZY_AI:sortAllSMahjongs( mahjong_MJZY)

    if  self.m_sSMahjongs == nil then
        return false
    end
    -- 由小到大的排列
    mahjong_MJZY:mahjongSort_stb( self.m_sSMahjongs)
    return true
end

----------------------------------------------------------------------------
-- 获取所有手牌
function CDMahjongMJZY_AI:getAllVMahjongs()
    return self.m_sVMahjongs
end

----------------------------------------------------------------------------
-- 获取所有摊牌
function CDMahjongMJZY_AI:getAllSMahjongs()
    return self.m_sSMahjongs
end

----------------------------------------------------------------------------
-- 获取所有扑倒牌组(只要数字)
function CDMahjongMJZY_AI:getAllSMahjongs_define()

    local array = {}
    local size = TABLE_SIZE( self.m_sSMahjongs)

    for i = 1, size do
        array[i] = self.m_sSMahjongs[i].mahjong
    end
    return array
end

----------------------------------------------------------------------------
-- 获取所有有效牌组除指定的牌以外(只删除一张指定的牌)
-- 参数: 指定的牌
function CDMahjongMJZY_AI:getAllVMahjongs_delMahjong( mahjong)

    local array = {}
    local size = TABLE_SIZE( self.m_sVMahjongs)

    local bFind = false
    for i = 1, size do

        if  ( self.m_sVMahjongs[i].mahjong ~= mahjong) or 
            ( self.m_sVMahjongs[i].mahjong == mahjong and bFind) then

            array[ TABLE_SIZE( array)+1] = self.m_sVMahjongs[i]
        else

            bFind = true
        end
    end
    return array
end

----------------------------------------------------------------------------
-- 搜索指定牌的数量在有效牌中
-- 参数: 指定要搜索数量的牌
function CDMahjongMJZY_AI:getMahjongCount_withV( mahjong)

    local size = TABLE_SIZE( self.m_sVMahjongs)
    local count = 0

    for i = 1, size do

        if  self.m_sVMahjongs[i].mahjong == mahjong then

            count = count + 1
        end
    end
    return count
end

----------------------------------------------------------------------------
-- 搜索指定牌数量在摊牌组中
-- 参数: 指定要搜索数量的牌
function CDMahjongMJZY_AI:getMahjongCount_withS( mahjong)

    local size = TABLE_SIZE( self.m_sSMahjongs)
    local count = 0

    for i = 1, size do

        if  self.m_sSMahjongs[i].mahjong == mahjong then

            count = count + 1
        end
    end
    return count
end

----------------------------------------------------------------------------
-- 搜索指定牌数量在所有无效牌中
-- 参数: 指定要搜索数量的牌
function CDMahjongMJZY_AI:getMahjongCount_withI( mahjong)

    local size = TABLE_SIZE( self.m_sIMahjongs)
    local count = 0

    for i = 1, size do

        if  self.m_sIMahjongs[i] == mahjong then

            count = count + 1
        end
    end
    return count
end

----------------------------------------------------------------------------
-- 搜索指定牌数量在所有摊牌和有效牌中
-- 参数: 指定要搜索数量的牌
function CDMahjongMJZY_AI:getMahjongCount_withSV( mahjong)

    local count = self:getMahjongCount_withV( mahjong)
    count = count + self:getMahjongCount_withS( mahjong)
    return count
end

----------------------------------------------------------------------------
-- 搜索指定牌数量在所有无效牌和有效牌中
-- 参数: 指定要搜索数量的牌
function CDMahjongMJZY_AI:getMahjongCount_withIV( mahjong)

    local count = self:getMahjongCount_withV( mahjong)
    count = count + self:getMahjongCount_withI( mahjong)
    return count
end

----------------------------------------------------------------------------
-- 在有效牌中选择作用最没用的牌
-- 参数: mahjong_MJZY_math类对象
-- 返回: 挑选出的牌的索引
function CDMahjongMJZY_AI:selectOutMahjong( mahjong_MJZY)

    local size = TABLE_SIZE( self.m_sVMahjongs)

    local laizi_count = 0 -- 假如两个赖子那么打出一个赖子
    for i = 1, size do
        if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
            laizi_count = laizi_count + 1
            if  laizi_count > 1 then
                return i
            end
        end
    end

    for i = 1, size do

        local mahjong = self.m_sVMahjongs[i].mahjong
        repeat

            if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
                break
            end 
            if  self:getMahjongCount_withV( mahjong) >= 3 then
                break
            end
            if  self:getMahjongCount_withV( mahjong) == 2 then
                break
            end
            if  ((mahjong%10 > 1) and self:getMahjongCount_withV( mahjong-1) > 0) or 
                ((mahjong%10 < 9) and self:getMahjongCount_withV( mahjong+1) > 0) then
                break
            end
            if  ((mahjong%10 > 2) and self:getMahjongCount_withV( mahjong-2) > 0) or 
                ((mahjong%10 < 8) and self:getMahjongCount_withV( mahjong+2) > 0) then
                break
            end
            return i
        until true
    end

    for i = 1, size do
        local mahjong = self.m_sVMahjongs[i].mahjong
        repeat

            if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
                break
            end 
            if  self:getMahjongCount_withV( mahjong) >= 3 then
                break
            end
            if  self:getMahjongCount_withV( mahjong) == 2 then
                break
            end
            if  ((mahjong%10 > 1) and self:getMahjongCount_withV( mahjong-1) > 0) or 
                ((mahjong%10 < 9) and self:getMahjongCount_withV( mahjong+1) > 0) then
                break
            end
            return i
        until true
    end

    for i = 1, size do
        local mahjong = self.m_sVMahjongs[i].mahjong
        repeat

            if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
                break
            end 
            if  self:getMahjongCount_withV( mahjong) >= 3 then
                break
            end
            if  self:getMahjongCount_withV( mahjong) == 2 then
                break
            end
            return i
        until true
    end

    for i = 1, size do
        local mahjong = self.m_sVMahjongs[i].mahjong
        repeat

            if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
                break
            end 
            if  self:getMahjongCount_withV( mahjong) >= 3 then
                break
            end
            return i
        until true
    end

    for i = 1, size do
        local mahjong = self.m_sVMahjongs[i].mahjong
        repeat

            if  mahjong == mahjong_MJZY:getMahjongLaiZi() then
                break
            end 
            return i
        until true
    end

    local index = math.random( 0, size-1)+1
    return index
end

----------------------------------------------------------------------------
-- 自己出牌
-- 参数: mahjong_MJZY_math类对象
-- 返回: 出的牌
function CDMahjongMJZY_AI:outMahjong_WithSelf( mahjong_MJZY)

    if  self.m_sVMahjongs == nil or TABLE_SIZE( self.m_sVMahjongs) == 0 then
        return -1
    end

    return self:selectOutMahjong( mahjong_MJZY)
end

----------------------------------------------------------------------------
-- 根据他人的牌判断碰、杠、胡、吃
-- 参数: mahjong_MJZY_math类对象,mahjong其他人打的牌
-- 返回: 类型(0无操作,1碰,2杠,4胡)
function CDMahjongMJZY_AI:outMahjong_WithOther( mahjong_MJZY, mahjong)

    local array = {}
    if  self.m_sVMahjongs == nil or TABLE_SIZE( self.m_sVMahjongs) == 0 then
        return 0, array
    end

    -- 判断是否胡牌, 假如有人飘过赖子那么一定不能胡别人的牌, 并且放弃过捉铳
    if  (not mahjong_MJZY:getFlagPiao()) and (not self:getNotCatch()) then

        local bHuPai, vecHuPai = mahjong_MJZY:canHuPai_WithOther( self.m_sVMahjongs, mahjong)
        if  bHuPai then

            if  mahjong_MJZY:checkHuPai_WithOther( vecHuPai, mahjong) then

                return DEF_JLHH_HU, vecHuPai
            end
        end
    end

    -- 遍历有效牌准备检索是否构成杠和碰
    local size = TABLE_SIZE( self.m_sVMahjongs)
    for i = 1, size do

        if  self.m_sVMahjongs[i].mahjong == mahjong then
            array[ TABLE_SIZE( array)+1] = mahjong
        end
    end
    size = TABLE_SIZE( array)

    if  mahjong_MJZY:getMahjongFan() == mahjong then

        if  size == 2 then      -- 翻牌三张就可以杠
            return DEF_JLHH_GANG, array
        end
    else

        if  size == 3 then      -- 杠
            return DEF_JLHH_GANG, array
        elseif size == 2 then   -- 碰
            return DEF_JLHH_PENG, array
        end
    end

    return 0, array
end

----------------------------------------------------------------------------
-- 根据他人的牌判断能否胡牌
-- 参数: mahjong_MJZY_math类对象,mahjong其他人打的牌
-- 返回: 是否胡牌，数组
function CDMahjongMJZY_AI:canHu_WithOther( mahjong_MJZY, mahjong)

    local array = {}
    if  self.m_sVMahjongs == nil or TABLE_SIZE( self.m_sVMahjongs) == 0 then
        return false, array
    end

    print("=============canHu_WithOther===============")
    print("self:getNotCatch()", self:getNotCatch())
    print("mahjong_MJZY:canZhuoPao( self.m_sVMahjongs, mahjong)", mahjong_MJZY:canZhuoPao( self.m_sVMahjongs, mahjong))
    print("=============canHu_WithOther===============")
    -- 判断是否胡牌, 假如有人飘过赖子那么一定不能胡别人的牌, 并且放弃过捉铳
    if  (not self:getNotCatch()) then
    --不可以捉混子的炮
        if mahjong ~= mahjong_MJZY:getMahjongLaiZi() then
            local bHuPai = mahjong_MJZY:canZhuoPao( self.m_sVMahjongs, mahjong)
            if  bHuPai then
                return true
            end
        end
    end
    return false, array
end

----------------------------------------------------------------------------
-- 根据他人的牌判断能否杠牌
-- 参数: mahjong_MJZY_math类对象,mahjong其他人打的牌
-- 返回: 是否杠牌，数组
function CDMahjongMJZY_AI:canGang_WithOther( mahjong_MJZY, mahjong)

    local array = {}
    if  self.m_sVMahjongs == nil or TABLE_SIZE( self.m_sVMahjongs) == 0 then
        return false, array
    end

    -- 遍历有效牌准备检索是否构成杠和碰
    local size = TABLE_SIZE( self.m_sVMahjongs)

    for i = 1, size do

        if  self.m_sVMahjongs[i].mahjong == mahjong and 
            mahjong ~= mahjong_MJZY:getMahjongLaiZi() then 
            array[ TABLE_SIZE( array)+1] = mahjong
        end
    end
    size = TABLE_SIZE( array)

    
    if  size == 3 then -- 普通杠

        return true, array
    end
    return false, array
end

----------------------------------------------------------------------------
-- 根据他人的牌判断能否碰牌
-- 参数: mahjong_MJZY_math类对象,mahjong其他人打的牌
-- 返回: 是否碰牌，数组
function CDMahjongMJZY_AI:canPeng_WithOther( mahjong_MJZY, mahjong)

    local array = {}
    if  self.m_sVMahjongs == nil or TABLE_SIZE( self.m_sVMahjongs) == 0 then
        return false, array
    end

    local size = TABLE_SIZE( self.m_sVMahjongs)
    local total = 1
    for i = 1, size do

        if  self.m_sVMahjongs[i].mahjong == mahjong and
            mahjong ~= mahjong_MJZY:getMahjongLaiZi() then 

            array[total] = mahjong
            total = total + 1
            --没有漏碰
            --if  total > 2 and (not self:isInForgoPeng( mahjong)) then
            if  total > 2  then
                return true, array
            end
        end
    end
    return false, array
end

----------------------------------------------------------------------------
-- 设置获取不课捉铳标记
function CDMahjongMJZY_AI:setNotCatch( bTrue)
    -- print("是否可以捉铳---->",bTrue)
    self.m_bNotCatch = bTrue
end
function CDMahjongMJZY_AI:getNotCatch()
    return self.m_bNotCatch
end
function CDMahjongMJZY_AI:resetCatch()
    self.m_bNotCatch = false
    self.m_pGangKai = false
end
----------------------------------------------------------------------------
-- 设置是否是杠后开花
function CDMahjongMJZY_AI:setGangType( boolean )
    self.m_pGangKai = boolean
end
function CDMahjongMJZY_AI:getGangType( ... )
    return self.m_pGangKai
end

-- 添加自己打出的牌 
function CDMahjongMJZY_AI:setOwnOutCard( card )
    if  self.m_sOutCards == nil then
        self.m_sOutCards ={}
    end
    self.m_sOutCards[TABLE_SIZE(self.m_sOutCards)+1] = card
end

-- 获取打出去的牌
function CDMahjongMJZY_AI:getOutCards( ... )
    if  self.m_sOutCards == nil then
        self.m_sOutCards ={}
    end
    return self.m_sOutCards
end
----------------------------------------------------------------------------
-- 获取杠的数据
function CDMahjongMJZY_AI:setGangTimes(  )
    self.gangTimes = self.gangTimes + 1
end
function CDMahjongMJZY_AI:setGangMatchTimes(  )

    self.gangMatchTimes = self.gangMatchTimes + 1
end
function CDMahjongMJZY_AI:getGangMatchTimes(  )
    return self.gangMatchTimes
end
----------------------------------------------------------------------------
-- 获取放弃提示
function CDMahjongMJZY_AI:getForgoMessage()
    local hadNewMessage = false

    local forgo_string = ""
    local visible = false

    if  self.m_bNotCatch then
        forgo_string = casinoclient.getInstance():findString("forgo_chong")
        visible = true
    end

--[[
    local count = TABLE_SIZE( self.m_sForgoGang)
    if  self.gangMatchTimes == count then
        visible = false
        forgo_string = ""
    else
        self.gangMatchTimes = 0

        local type  = casinoclient.getInstance():findString("forgo_gang")
        for i = 1, count do
            self:setGangMatchTimes()
            if  forgo_string == nil then

                forgo_string = string.format( "%s%s", 
                    casinoclient.getInstance():findString( string.format("mahjong%d", self.m_sForgoGang[i])), type)
            else

                local temp = string.format( "%s%s", 
                    casinoclient.getInstance():findString( string.format("mahjong%d", self.m_sForgoGang[i])), type)
                if  temp ~= nil then
                    forgo_string = forgo_string.." "..temp
                end
            end
            visible = true
        end
    end
    ]]

    count = TABLE_SIZE( self.m_sForgoPeng)
    local type  = casinoclient.getInstance():findString("forgo_peng")
    for i = 1, count do

        if  forgo_string == nil then

            forgo_string = string.format( "%s%s", 
                casinoclient.getInstance():findString( string.format("mahjong%d", self.m_sForgoPeng[i])), type)
        else

            local temp = string.format( "%s%s", 
                casinoclient.getInstance():findString( string.format("mahjong%d", self.m_sForgoPeng[i])), type)
            if  temp ~= nil then
                forgo_string = forgo_string.." "..temp
            end
        end
        visible = true
    end

    return visible, forgo_string
end

----------------------------------------------------------------------------
-- 创建AI对象
function CDMahjongMJZY_AI.create()
    cclog("CDMahjongMJZY_AI.create")
    local   instance = CDMahjongMJZY_AI.new()
    return  instance
end
