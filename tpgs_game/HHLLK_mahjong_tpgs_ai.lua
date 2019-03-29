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
require( "tpgs_game.HHLLK_mahjong_tpgs_math")

CDMahjongHHLLKTPGS_AI = class("CDMahjongHHLLKTPGS_AI")
CDMahjongHHLLKTPGS_AI.__index = CDMahjongHHLLKTPGS_AI

----------------------------------------------------------------------------
-- 变量
CDMahjongHHLLKTPGS_AI.m_nHHLLKExpGold         = 0          -- 消耗的金币数量
CDMahjongHHLLKTPGS_AI.m_nHHLLKTableLeftScore  = 0          -- 桌子中剩余的积分
CDMahjongHHLLKTPGS_AI.m_nNowLevel             = 1          -- 当前关卡数
CDMahjongHHLLKTPGS_AI.m_nLeftLife             = 0          -- 当前生命值
CDMahjongHHLLKTPGS_AI.m_nTotalTime            = 0          -- 总时间
----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKTPGS_AI:ctor()
    cclog("CDMahjongHHLLKTPGS_AI::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKTPGS_AI:init()
    cclog("CDMahjongHHLLKTPGS_AI:init")
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKTPGS_AI:release()
    cclog("CDMahjongHHLLKTPGS_AI:release")
    self:clearAllCards()
end

----------------------------------------------------------------------------
-- 增加已经消耗的金币
function CDMahjongHHLLKTPGS_AI:addExpGold(count)
    if count and count > 0 then
        self.m_nHHLLKExpGold = self.m_nHHLLKExpGold + count
    end
end

----------------------------------------------------------------------------
-- 积分累加
function CDMahjongHHLLKTPGS_AI:addScore(count)
    if count and count > 0 then
        self.m_nHHLLKTableLeftScore = self.m_nHHLLKTableLeftScore + count
    end

    return self.m_nHHLLKTableLeftScore
end

-- 关卡增加
function CDMahjongHHLLKTPGS_AI:addLevel()
    self.m_nNowLevel = self.m_nNowLevel + 1;
end

-- 生命扣除
function CDMahjongHHLLKTPGS_AI:deductLife()
    self.m_nLeftLife = self.m_nLeftLife - 1

    return self.m_nLeftLife
end

----------------------------------------------------------------------------
-- 设置玩家的ID
function CDMahjongHHLLKTPGS_AI:setPlayerID(playerId)
    self.m_nHHLLKPlayerId = playerId
end

function CDMahjongHHLLKTPGS_AI:getPlayerID()
    return self.m_nHHLLKPlayerId
end

----------------------------------------------------------------------------
function CDMahjongHHLLKTPGS_AI:addTotalTime(_time)
    if _time and _time>0 then
        self.m_nTotalTime = self.m_nTotalTime + _time
    end
end
----------------------------------------------------------------------------
function CDMahjongHHLLKTPGS_AI:getTotalTime()
    return self.m_nTotalTime 
end

function CDMahjongHHLLKTPGS_AI:clearTotalTime()
    self.m_nTotalTime = 0
end

----------------------------------------------------------------------------
-- 创建AI对象
function CDMahjongHHLLKTPGS_AI.create()
    cclog("CDMahjongHHLLKTPGS_AI.create")
    local   instance = CDMahjongHHLLKTPGS_AI.new()
    return  instance
end