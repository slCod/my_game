--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       QPHH_card_xtqf_ai(仙桃千分AI库)
//File Name:    QPHH_card_xtqf_ai.h
//Author:       GostYe
//Start Data:   2016.01.19
//Language:     XCode 4.5
//Target:       IOS, Android
/****************************************************************************
]]
-- require( "card_xtlzddz.QPHH_card_xtlzddz_math")
-- require( REQUIRE_PATH.."HHLLK_card_define")
require( "mahjong_llk.HHLLK_mahjong_llk_math")
require( "mahjong_llk.Mahjong_llk_item")

local casinoclient = require("script.client.casinoclient")

CDMahjongHHLLKLLK_AI = class("CDMahjongHHLLKLLK_AI")
CDMahjongHHLLKLLK_AI.__index = CDMahjongHHLLKLLK_AI

CDMahjongHHLLKLLK_AI.m_nHHLLKTableLeftMahjong  = 0          -- 桌子中剩余的麻将数量
CDMahjongHHLLKLLK_AI.m_nHHLLKExpGold           = 0          -- 消耗的金币数量

----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKLLK_AI:ctor()
    cclog("CDMahjongHHLLKLLK_AI::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKLLK_AI:init()
    cclog("CDMahjongHHLLKLLK_AI:init")
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKLLK_AI:release()
    cclog("CDMahjongHHLLKLLK_AI:release")
    self:clearAllCards()
end

----------------------------------------------------------------------------
-- 清理牌
function CDMahjongHHLLKLLK_AI:clearAllCards()
    self.m_nHHLLKTableLeftMahjong = 0 
end

----------------------------------------------------------------------------
-- 增加已经消耗的金币
function CDMahjongHHLLKLLK_AI:addExpGold(count)
    if count and count > 0 then
        self.m_nHHLLKExpGold = self.m_nHHLLKExpGold + count
    end
end

----------------------------------------------------------------------------
-- 剩余牌数相关设置
function CDMahjongHHLLKLLK_AI:lessLeftTableMahjong()
    self.m_nHHLLKTableLeftMahjong = self.m_nHHLLKTableLeftMahjong - 2
    if  self.m_nHHLLKTableLeftMahjong < 0 then
        self.m_nHHLLKTableLeftMahjong = 0
    end
end

function CDMahjongHHLLKLLK_AI:setLeftTableMahjong(count)
    if count and count > 0 then
        self.m_nHHLLKTableLeftMahjong = count
    end
end

function CDMahjongHHLLKLLK_AI:getLeftTableMahjong()
    return self.m_nHHLLKTableLeftMahjong
end

----------------------------------------------------------------------------
-- 设置玩家的ID
function CDMahjongHHLLKLLK_AI:setPlayerID(playerId)
    self.m_nHHLLKPlayerId = playerId
end

function CDMahjongHHLLKLLK_AI:getPlayerID()
    return self.m_nHHLLKPlayerId
end

----------------------------------------------------------------------------
-- 创建AI对象
function CDMahjongHHLLKLLK_AI.create()
    cclog("CDMahjongHHLLKLLK_AI.create")
    local   instance = CDMahjongHHLLKLLK_AI.new()
    return  instance
end