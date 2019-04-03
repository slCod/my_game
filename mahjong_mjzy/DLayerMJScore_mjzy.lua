--[[
/******************************************************
//Project:      ProjectX
//Moudle:       CDLayerMJScore_mjzy
//File Name:    DLayerMJScore.h
//Author:       GostYe
//Start Data:   2016.06.29
//Language:     XCode 4.5
//Target:       IOS, Android

ProjectX－麻将结算界面

******************************************************/
]]

require( REQUIRE_PATH.."DAniLayerBase")
require( "mahjong_mjzy.mahjong_mjzy_math")
require( REQUIRE_PATH.."DLayerMJ4Score")
--require "CCBReaderLoad"

local casinoclient = require("script.client.casinoclient")

-----------------------------------------
-- 类定义
CDLayerMJScore_mjzy = class("CDLayerMJScore_mjzy", CDAniLayerBase)
CDLayerMJScore_mjzy.__index = CDLayerMJScore_mjzy

-- 构造函数
function CDLayerMJScore_mjzy:ctor()
    cclog("CDLayerMJScore_mjzy::ctor")
    CDLayerMJScore_mjzy.super.ctor(self)
    CDLayerMJScore_mjzy.initialMember(self)

    local function onNodeEvent(event)
        if "exit" == event then
            CDLayerMJScore_mjzy.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerMJScore_mjzy:onExit()
    cclog("CDLayerMJScore_mjzy::onExit")
    self:stopAllActions()
    self:enableTouch(false)
    --模拟析构自身
    --uitest CDLayerMJScore_mjzy.releaseMember(self)
    --uitest self:unregisterScriptHandler()
end

DEF_MJZY_MAHJONG_SPACE_S = 33              -- 结算界面牌间距
-----------------------------------------
-- 成员变量定义
CDLayerMJScore_mjzy.m_pButReturn = nil     -- 返回大厅
CDLayerMJScore_mjzy.m_pTxtReturn = nil

CDLayerMJScore_mjzy.m_pButShare = nil      -- 分享
CDLayerMJScore_mjzy.m_pTxtShare = nil

CDLayerMJScore_mjzy.m_pButAgain = nil      -- 再来一局
CDLayerMJScore_mjzy.m_pTxtAgain = nil

CDLayerMJScore_mjzy.m_pPlayerGroup = nil   -- 玩家组

CDLayerMJScore_mjzy.m_pDemo_lz = nil       -- 赖子容器
CDLayerMJScore_mjzy.m_pDemo_sc = nil       -- 胜负容器
CDLayerMJScore_mjzy.m_pTime = nil          -- 时间显示
CDLayerMJScore_mjzy.m_pBase = nil          -- 底注

CDLayerMJScore_mjzy.m_nWaitTime = 0        -- 等待时间
CDLayerMJScore_mjzy.m_uServerTime = 0      -- 服务器时间

CDLayerMJScore_mjzy.isSelfRoom = false    -- 是否是自建房
-----------------------------------------
-- 初始化
function CDLayerMJScore_mjzy:initialMember()
    cclog("CDLayerMJScore_mjzy::initialMember")
    
    self.m_pButReturn = nil
    self.m_pTxtReturn = nil

    self.m_pButShare = nil
    self.m_pTxtShare = nil

    self.m_pButAgain = nil
    self.m_pTxtAgain = nil

    self.m_pPlayerGroup = {}
    for i = 1, 4 do

        self.m_pPlayerGroup[i] = {}
        self.m_pPlayerGroup[i].group = nil
        self.m_pPlayerGroup[i].name = nil
        self.m_pPlayerGroup[i].type_gang = nil
        self.m_pPlayerGroup[i].type_fc = nil
        self.m_pPlayerGroup[i].score = nil
        self.m_pPlayerGroup[i].ico_zhuang = nil
        self.m_pPlayerGroup[i].demo_mj = nil
        self.m_pPlayerGroup[i].demo_eff = nil
        self.m_pPlayerGroup[i].number_ttf1 = nil
        self.m_pPlayerGroup[i].number_ttf2 = nil
        self.m_pPlayerGroup[i].my_frame = nil
        self.m_pPlayerGroup[i].demo_hua = nil
        self.m_pPlayerGroup[i].pos = nil
    end

    self.m_pGroupLaiZi = nil
    self.m_pFrameLaiZi = nil

    self.m_pDemo_lz = nil
    self.m_pDemo_sc = nil
    self.m_pTime = nil
    self.m_pBase = nil

    self.m_nWaitTime = 0
    self.isSelfRoom = false
end

function CDLayerMJScore_mjzy:releaseMember()
    cclog("CDLayerMJScore_mjzy::releaseMember")
    
    --模拟析构父类
    CDAniLayerBase.releaseMember(self)
    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDLayerMJScore_mjzy.initialMember(self)

    self:unregisterScriptHandler()
end

-- 初始化
function CDLayerMJScore_mjzy:init()
    cclog("CDLayerMJScore_mjzy::init")
    CDAniLayerBase.init(self)
    return true
end


-----------------------------------------
-- 功能函数

-- 设置点击标志的开启和关闭
function CDLayerMJScore_mjzy:enableTouch( bEnable)

    if bEnable then

        if self.m_bTouch then
            return
        end

        -- touch事件
        local function onTouchBegan(touch, event)
            --if not dtIsRenderObjTouchable( self) then
            --    return false
            --end
            cclog("CDLayerMJScore_mjzy::onTouchBegan")
            return true
        end

        local function onTouchMoved(touch, event)
            --cclog("CDLayerMJScore_mjzy::onTouchMoved")
        end

        local function onTouchEnded(touch, event)
            cclog("CDLayerMJScore_mjzy::onTouchEnded")
        end

        self.m_pListener = cc.EventListenerTouchOneByOne:create()
        self.m_pListener:setSwallowTouches(true)
        self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)

    else

        if not self.m_bTouch then
            return
        end
        if self.m_pListener then
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:removeEventListener(self.m_pListener)
            self.m_pListener = nil
        end

    end
    self.m_bTouch = bEnable
end

-- 添加一张牌
function CDLayerMJScore_mjzy:addMahjongToDemo( demo, pos, mahjong, lai_zi)

    local temp = CDMahjong.createCDMahjong( demo)
    temp:initMahjongWithFile( string.format( "t_%u.png", mahjong))
    temp:setPosition( pos)
    temp:setMahjongScale( 0.65)
    if  mahjong == lai_zi then
        temp:setIcoLaiVisible( false, true)
    end
end

-- 改变对象编号根据玩家数
function CDLayerMJScore_mjzy:changeOrder( count, idx)

    if  count == 2 then
        return (idx + 1)
    end
    return idx
end

-- 设置界面数据
function CDLayerMJScore_mjzy:refreshInterface( data, mahjong_math, lord_id,table_mjzy)

    local effect = nil
    local eff_pos = cc.p( 0, 0)
    local count = TABLE_SIZE( data.scores)
    local bLiuJu = true
    local bMyWin = false

    for i = 1, 4 do
        self.m_pPlayerGroup[i].group:setVisible( false)
    end

    local ttf_scale = 1.0
    for i = 1, count do

        local player_score = data.scores[i]
        local order_idx = self:changeOrder( count, i)
        self.m_pPlayerGroup[order_idx].group:setVisible( true)

        -- 信息显示
        dtSetNickname( self.m_pPlayerGroup[order_idx].name, player_score.data.nickname, player_score.data.channel_nickname)

        local txt_score = nil
        if  player_score.score > 0 then

            txt_score = string.format( "+%s", dtGetFloatString( player_score.score))
            self.m_pPlayerGroup[order_idx].number_ttf2:setString( txt_score)
            self.m_pPlayerGroup[order_idx].number_ttf2:setVisible( true)
            self.m_pPlayerGroup[order_idx].number_ttf1:setVisible( false)
        elseif player_score.score < 0 then

            txt_score = dtGetFloatString( player_score.score)
            self.m_pPlayerGroup[order_idx].number_ttf1:setString( txt_score)
            self.m_pPlayerGroup[order_idx].number_ttf1:setVisible( true)
            self.m_pPlayerGroup[order_idx].number_ttf2:setVisible( false)
        else

            txt_score = "0"
            self.m_pPlayerGroup[order_idx].number_ttf2:setString( txt_score)
            self.m_pPlayerGroup[order_idx].number_ttf2:setVisible( true)
            self.m_pPlayerGroup[order_idx].number_ttf1:setVisible( false)
        end

        local tmp_scale = dtGetScaleWithTTF( self.m_pPlayerGroup[order_idx].score, txt_score, 34, 44)
        if  tmp_scale < ttf_scale then
            ttf_scale = tmp_scale
        end

        if  player_score.data.id == lord_id then
            self.m_pPlayerGroup[order_idx].ico_zhuang:setVisible( true)
        else
            self.m_pPlayerGroup[order_idx].ico_zhuang:setVisible( false)
        end

        if  player_score.data.id == casinoclient.getInstance():getPlayerData():getId() then
            self.m_pPlayerGroup[order_idx].my_frame:setVisible( true)
        else
            self.m_pPlayerGroup[order_idx].my_frame:setVisible( false)
        end

        -- 风牌显示
        local curIndex = table_mjzy:changeOrder( table_mjzy:getTableIndexWithID( player_score.data.id))
        local curHuaArray = table_mjzy.m_pPlayAI[curIndex]:getFangFMahjong()
        mahjong_math:defMahjongSort_stb(curHuaArray)
      
        self.m_pPlayerGroup[order_idx].demo_hua:removeAllChildren()
        local hua_count = TABLE_SIZE( curHuaArray)

        local hua_pos = cc.p( 0, 0)
        for j = 1, hua_count do
            local hua_ico = cc.Sprite:createWithSpriteFrameName( string.format( "t_%u.png",curHuaArray[j]))
            self.m_pPlayerGroup[order_idx].demo_hua:addChild( hua_ico)
            hua_ico:setPosition( hua_pos)
            hua_pos.x = hua_pos.x + 45
        end
        -- 麻将显示
        self.m_pPlayerGroup[order_idx].demo_mj:removeAllChildren()
        self.m_pPlayerGroup[order_idx].demo_eff:removeAllChildren()

        local bIsWin = false
        local curcards = {}
        mahjong_math:push_back( curcards, player_score.curcards, 1, TABLE_SIZE( player_score.curcards))

        --print("----------curcards-------------")
        --dumpArray(curcards)

        mahjong_math:defMahjongSort_stb( curcards)
        if  player_score.hupai_card > 0 then

            local bHu, mahjongs = mahjong_math:canHuPai_defEX( curcards)
            if  bHu then
                curcards = {}
                mahjong_math:push_back( curcards, mahjongs, 1, TABLE_SIZE( mahjongs))
                bIsWin = true
            end
            

            effect = CDCCBAniObject.createCCBAniObject( self.m_pPlayerGroup[order_idx].demo_eff, "x_tx_score_hu.ccbi", eff_pos, 0)
            if  effect ~= nil then
                effect:endRelease( false)
                effect:endVisible( false)
            end
            bLiuJu = false
            if  self.m_pPlayerGroup[order_idx].my_frame:isVisible() then --player_score.data.id == casinoclient:getInstance():getPlayerData():getId() then
                bMyWin = true
            end
        else -- 听牌判断

            local bTing = mahjong_math:canTingPaiEX( curcards)
            if  bTing then

                effect = CDCCBAniObject.createCCBAniObject( self.m_pPlayerGroup[order_idx].demo_eff, "x_tx_score_ting.ccbi", eff_pos, 0)
                if  effect ~= nil then
                    effect:endRelease( false)
                    effect:endVisible( false)
                end
            end
        end
       
        local sel_count = TABLE_SIZE( player_score.selcards)
        mahjong_math:defMahjongSort_stb( player_score.selcards)
        --print("-------扑倒的牌绘制----------")
        --dumpArray(player_score.selcards)
        -- 扑倒的牌绘制
        local pos = cc.p( 77, 35)
        local space = 0
        local previous = 0
        for j = 1, sel_count do

            space = space + 1

            self:addMahjongToDemo( self.m_pPlayerGroup[order_idx].demo_mj, pos, player_score.selcards[j], mahjong_math:getMahjongLaiZi())
            pos.x = pos.x + DEF_MJZY_MAHJONG_SPACE_S
            if  j >= sel_count then
                pos.x = pos.x + 5
            elseif (space >= 3) and (previous ~= player_score.selcards[j+1]) then
                pos.x = pos.x + 5
                space = 0
            end
            previous = player_score.selcards[j]
        end
        -- 胡的手牌绘制
        local cur_count = 0
        --是否是七对的牌型
        local isDDH = true
        local op_count = TABLE_SIZE( player_score.opscores)
        for i =1 ,op_count do 
            local op_scores = player_score.opscores[i]
            if op_scores.type == 241 then 
                isDDH = false
                break
            end
        end

        if  bIsWin then

            -- 获取前半段与后半段
            local sParray, sBarray = mahjong_math:getArray_hupai( curcards, player_score.hupai_card,isDDH)
            --print("胡的手牌绘制")
            --dumpArray(sParray)
            --dumpArray(sBarray)
            -- 绘制前半段
            cur_count = TABLE_SIZE( sParray)
            for j = 1, cur_count do

                self:addMahjongToDemo( self.m_pPlayerGroup[order_idx].demo_mj, pos, sParray[j], mahjong_math:getMahjongLaiZi())
                pos.x = pos.x + DEF_MJZY_MAHJONG_SPACE_S
            end
            -- 绘制后半段
            cur_count = TABLE_SIZE( sBarray)
            if  cur_count > 0 then

                mahjong_math:pop_mahjong( sBarray, player_score.hupai_card)
                cur_count = TABLE_SIZE( sBarray)
                for j = 1, cur_count do

                    self:addMahjongToDemo( self.m_pPlayerGroup[order_idx].demo_mj, pos, sBarray[j], mahjong_math:getMahjongLaiZi())
                    pos.x = pos.x + DEF_MJZY_MAHJONG_SPACE_S
                end
                -- 最后一张胡的牌
                pos.x = pos.x + 10
                self:addMahjongToDemo( self.m_pPlayerGroup[order_idx].demo_mj, pos, player_score.hupai_card, mahjong_math:getMahjongLaiZi())
            end
        else

            cur_count = TABLE_SIZE( curcards)
            for j = 1, cur_count do

                self:addMahjongToDemo( self.m_pPlayerGroup[order_idx].demo_mj, pos, curcards[j], mahjong_math:getMahjongLaiZi())
                pos.x = pos.x + DEF_MJZY_MAHJONG_SPACE_S
            end
        end

        self.m_pPlayerGroup[order_idx].demo_hua:setPositionX( pos.x + 100)

        -- 其他参数显示( 杠信息，放铳信息，飘赖子信息)
        self.m_pPlayerGroup[order_idx].type_gang:setVisible( false)
        self.m_pPlayerGroup[order_idx].type_fc:setVisible( false)

        local op_count = TABLE_SIZE( player_score.opscores)
        local op_string = nil
        local game_id = g_pGlobalManagement:getGameID()
      
        for j = 1, op_count do
            -- 228 软摸，229 硬摸 230 软胡 231 硬胡 放铳 217
            local op_scores = player_score.opscores[j]
            print("op_scores-------->",op_scores.type)
            if  op_scores.type == 228 or op_scores.type == 229  
                or op_scores.type == 230 or op_scores.type == 231 or op_scores.type == 217 then

                self.m_pPlayerGroup[order_idx].type_fc:setString( casinoclient.getInstance():findString( string.format("%u_score_msg%u",DEF_CASINO_AREA, op_scores.type)))
                self.m_pPlayerGroup[order_idx].type_fc:setVisible( true)
                
                --明杠，暗杠,七对
            elseif  op_scores.type == 242 or op_scores.type == 243 or op_scores.type == 241 then
                
                local op_count = op_scores.count
                print("op_count------->",op_count)
                for z = 1, op_count do

                    local temp = casinoclient.getInstance():findString( string.format("%u_score_msg%u",DEF_CASINO_AREA, op_scores.type))
                        
                    if  op_string == nil then

                        op_string = temp
                    else
                        
                        if  temp ~= nil then
                            op_string = op_string.."/"..temp
                        end
                    end
                end
            end
        end

        --跑风
        local curIndex = table_mjzy:changeOrder( table_mjzy:getTableIndexWithID( player_score.data.id))
        local paoFengArrSize = table_mjzy.m_pPlayAI[curIndex]:getPaoFMahjongSize()
        local tempPaoFStr = nil
        if paoFengArrSize >0 then
            tempPaoFStr  = string.format(casinoclient.getInstance():findString(string.format("130_score_paoFeng")),paoFengArrSize)
        end

        if tempPaoFStr ~= nil then
            if op_string == nil then
                op_string = tempPaoFStr
            else
                op_string = op_string.."/"..tempPaoFStr
            end
        end
       

        if  op_string ~= nil then
            self.m_pPlayerGroup[order_idx].type_gang:setString( op_string)
            self.m_pPlayerGroup[order_idx].type_gang:setVisible( true)
        end
    end

    -- 调整积分显示的尺寸
    for i = 1, count do
        local order_idx = self:changeOrder( count, i)
        self.m_pPlayerGroup[order_idx].score:setScale( ttf_scale)
    end

    -- 假如是两人那么调整位置
    if  count == 2 then
        self.m_pPlayerGroup[2].group:setPosition( cc.p( self.m_pPlayerGroup[2].pos.x, 
            (self.m_pPlayerGroup[2].pos.y + self.m_pPlayerGroup[1].pos.y)*0.42))
        self.m_pPlayerGroup[3].group:setPosition( cc.p( self.m_pPlayerGroup[3].pos.x, 
            (self.m_pPlayerGroup[3].pos.y + self.m_pPlayerGroup[4].pos.y)*0.58))
    end

    -- 赖子显示
    self.m_pDemo_lz:removeAllChildren()
    if  mahjong_math:getMahjongLaiZi() > 0 then

        local mahjong_lz = CDMahjong.createCDMahjong( self.m_pDemo_lz)
        mahjong_lz:initMahjongWithFile( string.format( "t_%u.png", mahjong_math:getMahjongLaiZi()))
        mahjong_lz:setMahjongScale( 0.95)
        mahjong_lz:setIcoLaiVisible( false, true)

        if  self.m_pGroupLaiZi ~= nil then
            self.m_pGroupLaiZi:setVisible( true)
        end
        if  self.m_pFrameLaiZi ~= nil then
            self.m_pFrameLaiZi:setVisible( true)
        end
    else

        if  self.m_pGroupLaiZi ~= nil then
            self.m_pGroupLaiZi:setVisible( false)
        end
        if  self.m_pFrameLaiZi ~= nil then
            self.m_pFrameLaiZi:setVisible( false)
        end
    end

    -- 胜负Title显示
    self.m_pDemo_sc:removeAllChildren()
    if  not bLiuJu then

        if  bMyWin then

            effect = CDCCBAniObject.createCCBAniObject( self.m_pDemo_sc, "x_tx_score_win.ccbi", eff_pos, 0)
            dtPlaySound( DEF_SOUND_WIN)

            -- -- 假如微信开启那么可以分享
            -- if  g_pGlobalManagement:getWeiXinLoginEnable() then
            --     self.m_pButShare:setVisible( true)
            --     self.m_pTxtShare:setVisible( true)
            -- end
        else

            effect = CDCCBAniObject.createCCBAniObject( self.m_pDemo_sc, "x_tx_score_lost.ccbi", eff_pos, 0)
            dtPlaySound( DEF_SOUND_LOST)
        end
    else

        effect = CDCCBAniObject.createCCBAniObject( self.m_pDemo_sc, "x_tx_score_liuju.ccbi", eff_pos, 0)
    end
    if  effect ~= nil then
        effect:endRelease( false)
        effect:endVisible( false)
    end

    -- 服务器时间
    self.m_pTime:setString( dtGetTimeString_ex( casinoclient.getInstance():getServerTime()))

    -- 底注
    self.m_pBase:setString( string.format( casinoclient.getInstance():findString("table_info"), dtGetFloatString( g_pGlobalManagement:getTableBase())))
end

-- 开启
-- 参数:结算数据, 再来一局对应函数, 庄家编号, 停留时间
function CDLayerMJScore_mjzy:open( data, mahjong_math, lord_id, time,table_mjzy)

    if  casinoclient.getInstance():isSelfBuildTable() then
        self.isSelfRoom = true
    end

    self:onLoadUI()

    -- 文字对象创建
    for i = 1, 4 do

        if  self.m_pPlayerGroup[i].number_ttf1 == nil then

            self.m_pPlayerGroup[i].number_ttf1 = cc.LabelAtlas:_create(  "0", "x_number_ex1.png", 34, 44, string.byte("*"))
            self.m_pPlayerGroup[i].number_ttf1:setAnchorPoint( cc.p( 0.5, 0.5))
            self.m_pPlayerGroup[i].number_ttf1:setVisible( false)
            self.m_pPlayerGroup[i].score:addChild( self.m_pPlayerGroup[i].number_ttf1)
        end
        if  self.m_pPlayerGroup[i].number_ttf2 == nil then
            self.m_pPlayerGroup[i].number_ttf2 = cc.LabelAtlas:_create(  "0", "x_number_ex2.png", 34, 44, string.byte("*"))
            self.m_pPlayerGroup[i].number_ttf2:setAnchorPoint( cc.p( 0.5, 0.5))
            self.m_pPlayerGroup[i].number_ttf2:setVisible( false)
            self.m_pPlayerGroup[i].score:addChild( self.m_pPlayerGroup[i].number_ttf2)
        end
    end

    self.m_bVisible = false
    self:setVisible( false)

    self:enableTouch( true)
    
    self:setVisible( true)

    self.m_pButShare:setVisible( false)
    self.m_pTxtShare:setVisible( false)
    self:refreshInterface( data, mahjong_math, lord_id,table_mjzy)

    local isQuitRoom = true    --用来判断是否退出房间 防止多次执行
    local function refreshWaitTime()     -- 显示积分界面
        --云信
        if isQuitRoom then
            if DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
                if dtIsAndroid() then
                    platform_help.quitAllTeam()
                    platform_help.setIsGame(0)
                else
                    NIMSDKopen:getInstance():quitAllTeam()
                    NIMSDKopen:getInstance():setIsInGame(false)
                end
            end
            isQuitRoom = false
        end

        if  self.m_nWaitTime > 0 then

            self.m_nWaitTime = self.m_nWaitTime - 1
            if  self.m_nWaitTime <= 10 then
                dtPlaySound( DEF_SOUND_TIME)
            end
            self.m_pButAgain:setTitleForState( string.format( casinoclient:getInstance():findString("again_time"), self.m_nWaitTime), cc.CONTROL_STATE_NORMAL)
            self.m_pTxtAgain:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( refreshWaitTime)))
        else
            self:onAgain()
        end
    end

    local function refreshGoto4ScoreTime()
        --云信
        if isQuitRoom then
            if DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
                if dtIsAndroid() then
                    platform_help.quitAllTeam()
                    platform_help.setIsGame(0)
                else
                    NIMSDKopen:getInstance():quitAllTeam()
                    NIMSDKopen:getInstance():setIsInGame(false)
                end
            end
            isQuitRoom = false
        end

        if  self.m_nWaitTime > 0 then

            self.m_nWaitTime = self.m_nWaitTime - 1
            if  self.m_nWaitTime <= 10 then
                dtPlaySound( DEF_SOUND_TIME)
            end
            self.m_pButAgain:setTitleForState( string.format( casinoclient:getInstance():findString("score_time"), self.m_nWaitTime), cc.CONTROL_STATE_NORMAL)
            self.m_pTxtAgain:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( refreshGoto4ScoreTime)))
        else
            
            self:onAgain()
           
        end
    end

    -- 有停留时间限制那么说明是自建房
    self.m_pButAgain:setVisible( true)
    local table_data = casinoclient:getInstance():getTable()
    if  casinoclient:getInstance():isSelfBuildTable() then

        self.m_pButReturn:setVisible( false)
        self.m_pTxtReturn:setVisible( false)

        self.m_pTxtAgain:setVisible( false)
        self.m_pTxtAgain:stopAllActions()
        self.m_nWaitTime = time
        self.m_uServerTime = casinoclient.getInstance():getServerTime()

        if  table_data.play_total >= table_data.round then

            self.m_pButAgain:setTitleForState( string.format( casinoclient:getInstance():findString("score_time"), self.m_nWaitTime), cc.CONTROL_STATE_NORMAL)
            self.m_pTxtAgain:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( refreshGoto4ScoreTime)))
        else

            self.m_pButAgain:setTitleForState( string.format( casinoclient:getInstance():findString("again_time"), self.m_nWaitTime), cc.CONTROL_STATE_NORMAL)
            self.m_pTxtAgain:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( refreshWaitTime)))
        end
    else

        self.m_pButReturn:setVisible( true)
        self.m_pTxtReturn:setVisible( true)

        self.m_pTxtAgain:setVisible( true)
        self.m_pButAgain:setTitleForState( "", cc.CONTROL_STATE_NORMAL)
    end

    dtPlaySound( DEF_SOUND_MOVE)
end

-- 关闭界面
function CDLayerMJScore_mjzy:close()

    -- self:onClose(true)
    self:enableTouch( false)
    self:setVisible( false)

    if  self.m_pTxtAgain ~= nil then
        self.m_pTxtAgain:stopAllActions()
    end
end

-- 返回大厅
function CDLayerMJScore_mjzy:onReturn()

    if  self.m_pButReturn:isVisible() then

        dtPlaySound( DEF_SOUND_TOUCH)
        g_pSceneTable:gotoSceneHall()
    end
end

-- 分享
function CDLayerMJScore_mjzy:onShare()

    if  self.m_pButShare:isVisible() then
        Channel:getInstance():share( casinoclient.getInstance():findString("share_game"), DEF_SHARE_TYPE4, "")
    end
end

-- 再来一局
function CDLayerMJScore_mjzy:onAgain()
    --云信
    if DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
        if dtIsAndroid() then
            platform_help.quitAllTeam()
            platform_help.setIsGame(0)
        else
            NIMSDKopen:getInstance():quitAllTeam()
            NIMSDKopen:getInstance():setIsInGame(false)
        end
    end
    
    if  self.m_pButAgain:isVisible() then

        self.m_pButAgain:setVisible( false)
        self.m_pTxtAgain:stopAllActions()
        if  self.isSelfRoom then

            local table_data = casinoclient.getInstance():getTable()
            if  table_data.play_total >= table_data.round then
                --进入四人积分画面显示
                g_pSceneTable.m_pLayerMJ4Score:open( table_data.tag)
            else
                dtOpenWaiting( self)
                g_pSceneTable.m_pLayerTable:myMahjong_ready()
                casinoclient.getInstance():sendTableReadyReq()
                g_pSceneTable.m_pLayerTable:showLeftTimeWaitReady( self.m_nWaitTime)
            end
        else
            
            dtOpenWaiting( self)
            casinoclient.getInstance():sendTableJoinReq( g_pGlobalManagement:getGameID(), 0, 0)
        end
    end
    self:close()
end

-- 动画播放完的回调处理
function CDLayerMJScore_mjzy:completedAnimationSequenceNamed(name)

    CDAniLayerBase.completedAnimationSequenceNamed(self, name)
end

-----------------------------------------
-- ccb处理

function CDLayerMJScore_mjzy:onAssignCCBMemberVariable(loader)
    cclog("CDLayerMJScore_mjzy::onAssignCCBMemberVariable")

    self.m_pButReturn = loader["but_return"]
    self.m_pTxtReturn = loader["txt_fhdt"]

    self.m_pButShare = loader["but_share"]
    self.m_pTxtShare = loader["txt_fx"]

    self.m_pButAgain = loader["but_again"]
    self.m_pTxtAgain = loader["txt_zlyj"]

    for i = 1, 4 do

        self.m_pPlayerGroup[i].group = loader["player_group"..i]
        self.m_pPlayerGroup[i].name = loader["name"..i]
        self.m_pPlayerGroup[i].type_gang = loader["gang_type"..i]
        self.m_pPlayerGroup[i].type_fc = loader["fc_type"..i]
        self.m_pPlayerGroup[i].score = loader["score"..i]
        self.m_pPlayerGroup[i].ico_zhuang = loader["ico_zhuang"..i]
        self.m_pPlayerGroup[i].demo_mj = loader["mj_demo"..i]
        self.m_pPlayerGroup[i].demo_eff = loader["eff_demo"..i]
        self.m_pPlayerGroup[i].my_frame = loader["my_frame"..i]
        self.m_pPlayerGroup[i].demo_hua = loader["hua_demo"..i]

        if  self.m_pPlayerGroup[i].group ~= nil then
            self.m_pPlayerGroup[i].pos = cc.p( self.m_pPlayerGroup[i].group:getPositionX(), 
                self.m_pPlayerGroup[i].group:getPositionY())
        end
    end

    self.m_pGroupLaiZi = loader["group_laizi"]
    self.m_pFrameLaiZi = loader["frame_laizi"]

    self.m_pDemo_lz = loader["laizi_demo"]
    self.m_pDemo_sc = loader["eff_demo"]
    self.m_pTime = loader["time"]
    self.m_pBase = loader["base"]

    -- 基类注册
    self:assignCCBMemberVariable(loader)
end

function CDLayerMJScore_mjzy:onResolveCCBCCControlSelector(loader)

    loader["onReturn"] = function() self:onReturn() end
    loader["onShare"]  = function() self:onShare() end
    loader["onAgain"]  = function() self:onAgain() end
end


-----------------------------------------
-- create
function CDLayerMJScore_mjzy.createCDLayerMJScore_mjzy(pParent)
    cclog("CDLayerMJScore_mjzy::createCDLayerMJScore_mjzy")
    if not pParent then
        return nil
    end
    local layer = CDLayerMJScore_mjzy.new()
    layer:init()
    pParent:addChild(layer)

    return layer
end

function CDLayerMJScore_mjzy:onLoadUI()

    if self.m_ccbLayer then
        return self
    end
    local layer = self

    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerMJScore_mjzy.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    return self
end
