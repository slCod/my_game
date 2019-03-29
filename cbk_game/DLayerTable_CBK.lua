--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerTable_CBK 仙桃赖子斗地主桌子
//File Name:    DLayerCardTable_xtlzddz.h
//Author:       GostYe
//Start Data:   2016.12.27
//Language:     XCode 4.5
//Target:       IOS, Android

-- 在调用前，需要先设置 m_nPlayers 玩家
-- 进入类后，先调用createUserInterface

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( REQUIRE_PATH.."_tkd_tbmenu")

require( "cbk_game.block_item")
require( REQUIRE_PATH.."mahjong_define")

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")


--屏幕的尺寸
local ScreenSize = CDGlobalMgr:sharedGlobalMgr():getWinSize()

GAME_BLOCK_WIDTH = 2
DEF_MAX_ROW      = 200

-- 音效定义
DEF_SOUND_MJ_CLICK      = "sound_card_click"..DEF_TKD_SOUND     -- 点中牌
DEF_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                -- 开局
DEF_SOUND_CMJ       = "sound_cmj"..DEF_TKD_SOUND            -- 踩麻将的声音
-----------------------------------------
-- 类定义
CDLayerTable_CBK = class("CDLayerTable_CBK", CDCCBLayer)    
CDLayerTable_CBK.__index = CDLayerTable_CBK
CDLayerTable_CBK.name = "CDLayerTable_CBK"

-- 构造函数
function CDLayerTable_CBK:ctor()
    cclog("CDLayerTable_CBK::ctor")
    CDLayerTable_CBK.super.ctor(self)
    CDLayerTable_CBK.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_CBK.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_CBK.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_CBK:onEnter()
    cclog("CDLayerTable_CBK::onEnter")

    -- 网络事件
    local   listeners = {
    }

    casinoclient.getInstance():addEventListeners(self,listeners)

    --暂时使用的心跳循环
    --self:createHeartbeatLoop()
end

function CDLayerTable_CBK:onExit()
    cclog("CDLayerTable_CBK::onExit")
    -- if self.playAudioID then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
    --     self.playAudioID=nil
    -- end

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerTable_CBK.releaseMember(self)
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 初始化
function CDLayerTable_CBK:initialMember()
    cclog("CDLayerTable_CBK::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pGroupBar        = nil        -- 状态按钮根节点
    self.m_pButSetting      = nil        -- 设置按钮
    self.m_pSelfInfo        = nil        -- 自己的信息
    self.m_pTableInfo       = nil        -- 桌子的信息
    ---------------------------------------------------
    self.m_pCloseBtn        = nil        -- 关闭设置按钮
    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pNewEffLayer     = nil        -- 特效层
    self.m_pNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pBlockLayer      = nil
    self.m_pLighting        = nil        -- 灯光
   
    self.m_pBlockDemo       = nil        -- block放置层

    self.m_pMahjongShowLayer = nil       -- 麻将放置层
    ---------------------------------------------------
    -- 电池
    self.m_pIcoPower        = nil        -- 电池图标

    self.m_pLayerLastView  = nil
    self.m_pNodeLastView  = nil          --胜利或失败界面Node
  
    self.m_pBtnGoToHall   = nil
    self.m_pBtnRestart    = nil
   
    self.m_pSettingBtn   = nil
------------------------------------
    self.m_pSettingNode  = nil

    self.m_pSoundOpen   = nil
    self.m_pSoundClose  = nil
    self.m_pMusicOpen   = nil
    self.m_pMusicClose  = nil

    self.m_pSoundOpenBtn   = nil
    self.m_pSoundCloseBtn  = nil
    self.m_pMusicOpenBtn   = nil
    self.m_pMusicCloseBtn  = nil

    self.m_pttf             = nil    -- 显示时间的label

    ---------------------------------------------------
    self.m_pListener        = nil        -- 监听对象
 
    self.m_bPreCreate       = false      -- 是否预创建过

    self.m_nFlag            = nil        -- 游戏类型(1、经典 2、挑战)
   
    ---------------------------------------------------
    self.m_pBlock         =  {} 
    -- 数据对象
    self.m_nNeedTouch      = 25           -- 需要点击的数量
    self.m_nRow            = 4           -- 行数和列数
    
    self.m_pBlockArr       = {}

    for i=1 ,DEF_MAX_ROW do
        self.m_pBlockArr[i]={}
    end

    self.m_bIsWin          = false      -- 是否胜利
    self.m_bIsTouchSetting = false      -- 是否点击设置

    self.m_nTouchNum        = 0 

    self.m_nCurNomalIndex  = 0           -- 当前的行数

    self.m_nIndex          = 1          -- 记录上次的点击 ，默认为1

    self.m_nLastIndex  = 0

    self.m_bTouchEndLine  = false        --选择行的点击判断

    --模式2 下

    self.m_nTouchFaCai      = 0          -- 踩中发财的数量

    self.m_arrFaCaiIndex      = {}       -- 保存发财的位置

    self.m_arrNotFaCaiIndex   = {}       -- 保存另一张随机出的位置
    ----------------------
    self.m_nTouchRow     =  1            --  需要点击的行数

    self.m_nRecordTime  =  0             -- 记录时间

    self.m_nJiSuTouchNum  = 0 

    self.m_pBlockVec = {}                -- 模式 3下存储数组

    self.m_nCurCount = 1

    self.m_nCurCheckIndex  = 2           -- 需要点击判断的位置

end

function CDLayerTable_CBK:releaseMember()
    cclog("CDLayerTable_CBK::releaseMember")

    if  self.m_pNewEffLayer then
        self.m_pNewEffLayer:removeAllChildren()
    end

    if  self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pEffNetLow = nil
    end

    if self.m_pBlockLayer ~= nil then
        self.m_pBlockLayer:removeAllChildren()
    end

    --模拟析构父类
    CDLayerTable_CBK.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end


-- 循环发送心跳包
function CDLayerTable_CBK:createHeartbeatLoop( ... )
    local waitTime=0
    local function sendHeartLoop( event )
        waitTime=waitTime+1
        if  waitTime > 30 then
            waitTime = 0
            casinoclient.getInstance():sendPong()
        end
    end
    if  not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sendHeartLoop,1,false)
    end
end

-- 停止发送心跳包
function CDLayerTable_CBK:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
---------------------------------------------------------------------------
--显示最下方的一行
function CDLayerTable_CBK:addStartLine(index)
   
    if self.m_nFlag == 1 then -- 经典模式

        local blockWidth  = (ScreenSize.width - (GAME_BLOCK_WIDTH)*4)/5
        local blockHeight = (ScreenSize.height- (GAME_BLOCK_WIDTH)*4)/5

        local str =""
        local layerColor 
        local textColor 

        for i=1 ,5 do
            if i==1 then
                str = "25"
            elseif i==2 then
                str = "50"
            elseif i==3 then
                str = "不连续"
            elseif i == 4 then
                str = "5*5"
            else
                str ="6*6"
            end

            if i== index then
                layerColor = cc.c3b(0,0,0)
                textColor  = cc.c3b(255,255,255)
            else
                layerColor = cc.c3b(255,255,0)
                textColor = cc.c3b(0,0,0)
            end
             
            self.m_pBlock[i] = CDBlockItem:createdBlockItem()
            self.m_pBlock[i]:createBlock(layerColor,cc.size(blockWidth,blockHeight),str,26,textColor)
            self.m_pBlock[i]:setPosition(cc.p(0,ScreenSize.height/5*(i-1)))
            self.m_pBlockDemo:addChild(self.m_pBlock[i])
        end
    elseif self.m_nFlag == 2 then
        local str = "踩两张发财！！！！"
        self.m_pBlock = CDBlockItem:createdBlockItem()
        self.m_pBlock:createBlock(cc.c3b(67,205,128),cc.size(ScreenSize.width/5,ScreenSize.height),str,36,cc.c3b(0,0,0))  
        self.m_pBlock:setPosition(cc.p(0,0))
        self.m_pBlockDemo:addChild(self.m_pBlock)
    elseif self.m_nFlag == 3 then

        local blockWidth  = (ScreenSize.width - (GAME_BLOCK_WIDTH)*4)/5
        local blockHeight = (ScreenSize.height- (GAME_BLOCK_WIDTH)*3)/4

        local str =""
        local layerColor 
        local textColor 

        for i=1 ,4 do
            if i==1 then
                str = "4*4"
            elseif i==2 then
                str = "不连续"
            elseif i == 3 then
                str = "5*5"
            else
                str ="6*6"
            end

            if i== index then
                layerColor = cc.c3b(0,0,0)
                textColor  = cc.c3b(255,255,255)
            else
                layerColor = cc.c3b(255,255,0)
                textColor = cc.c3b(0,0,0)
            end
             
            self.m_pBlock[i] = CDBlockItem:createdBlockItem()
            self.m_pBlock[i]:createBlock(layerColor,cc.size(blockWidth,blockHeight),str,26,textColor)
            self.m_pBlock[i]:setPosition(cc.p(0,ScreenSize.height/4*(i-1)))
            self.m_pBlockDemo:addChild(self.m_pBlock[i])
        end

    end
end
------------------------------------------------------------------------------------------
--创建按钮
function CDLayerTable_CBK:createControlBtn(parent,spriteFrame,pos,size,callBack_Func)

    if not parent then
        return nil
    end
    local scale9Sprite = cc.Scale9Sprite:createWithSpriteFrameName(spriteFrame)
    local Button = cc.ControlButton:create(scale9Sprite)
    Button:setPosition(pos)
    Button:setPreferredSize(cc.size(size.width,size.height))

    Button:registerControlEventHandler(callBack_Func,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    parent:addChild(Button)

    return Button
end

--创建 label
function CDLayerTable_CBK:createLabel(parent,str,fontSize,textColor,pos)
    if not parent then
        return nil
    end
    local label = cc.Label:create()
    label:setString(str)
    label:setSystemFontSize(fontSize)

    label:setTextColor(textColor)
    label:setPosition(pos)
    parent:addChild(label)

    return label
end
    
--创建 sprite
function CDLayerTable_CBK:createSprite(parent,spriteStr,pos,anchorPoint,isVisible)

    if not parent then
        return nil
    end

    local curSprite= cc.Sprite:createWithSpriteFrameName(spriteStr)
    curSprite:setPosition(pos)
    curSprite:setAnchorPoint(anchorPoint)
    curSprite:setVisible(isVisible)
    parent:addChild(curSprite)

    return curSprite
end

------------------------------------------------------------------------------------------

function CDLayerTable_CBK:showWinView()

    if self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(false)
    end

    local function returnView()
        
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 

    local function againNext()
        if self.m_pEndLineBlock then
            self.m_pEndLineBlock:removeFromParent()
            self.m_pEndLineBlock = nil
        end
        self:clearData()
        self:StartNextGame()
    end 

    local curPos  = cc.p(ScreenSize.width/3*2,180)
    local curSize = cc.size(210,90)
    local btn1=self:createControlBtn(self.m_pNewLayerRoot,"returnBtn.png",curPos,curSize,returnView)
    btn1:setRotation(-90)

    curPos = cc.p(ScreenSize.width/3*2,480)
    local btn2=self:createControlBtn(self.m_pNewLayerRoot,"againBtn.png",curPos,curSize,againNext)
    btn2:setRotation(-90)

    local textColor = cc.c3b(255,255,255)
    curPos = cc.p(50,100)
    local label1=self:createLabel(self.m_pNewLayerRoot,"游戏玩法:",40,textColor,curPos)
    label1:setRotation(-90)

    curPos = cc.p(ScreenSize.width/3,ScreenSize.height/2)
    local label2=self:createLabel(self.m_pNewLayerRoot,"经典模式",60,textColor,curPos)
    label2:setRotation(-90)

    local str  = string.format("%.3f".."'' ",self.m_nRecordTime)
    textColor = cc.c3b(0,0,0)
    curPos = cc.p(ScreenSize.width/2-60,ScreenSize.height/2+30)
    local label3= self:createLabel(self.m_pNewLayerRoot,str,120,textColor,curPos)
    label3:setRotation(-90)

    local posX = 225
    if self.m_nIndex == 1 then
        str = "25"
    elseif self.m_nIndex == 2 then
        str = "50"
    elseif self.m_nIndex == 3 then
        str = "不连续"
        posX = 250
    elseif self.m_nIndex == 4 then
        str = "5*5"
    elseif self.m_nIndex == 5 then
        str = "6*6"
    end
    curPos = cc.p(50,posX)
    local label4 =self:createLabel(self.m_pNewLayerRoot,str,40,textColor,curPos)
    label4:setRotation(-90)
end

function CDLayerTable_CBK:recordTime()
    if self.m_bIsWin then
        if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)~= 0 then
            if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) >self.m_nRecordTime then
                g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
            end
        else
            g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
        end
    end
end

function CDLayerTable_CBK:addEndLineBlock()

    self:recordTime()
    self.m_pRecordttf = cc.LabelTTF:create("0.000","Courier New",60)
    self.m_pRecordttf:setColor(cc.c3b(255,0,0))
    self.m_pRecordttf:setLocalZOrder(100)
    self.m_pRecordttf:setPosition(cc.p(ScreenSize.width/2+60,ScreenSize.height/2))
    self.m_pRecordttf:setRotation(-90)
    self.m_pNewLayerRoot:addChild(self.m_pRecordttf)
    if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) < self.m_nRecordTime then
        self.m_pRecordttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
    else
        self.m_pRecordttf:setString("新纪录!")
    end

    self:showWinView()
end

function CDLayerTable_CBK:randInChallenge(num)

    local saveBlockIndex = {}
    if num>0 and num % 8 == 0 then
       
        -- 两个黑block
        local arr  = {1,2,3,4,5,6}
        local index = math.random(6)
        table.insert(saveBlockIndex,arr[index])
        table.remove(arr,index)

        index = math.random(5)
        table.insert(saveBlockIndex,arr[index])

    else
        
        local index = math.random(6)
        table.insert(saveBlockIndex,index)
    end
    return saveBlockIndex
end


--参数：设置的行数,一行有几个
function CDLayerTable_CBK:addNormalLineBlocks(lineCount,row)

    self.m_nCurNomalIndex = self.m_nCurNomalIndex +1
    local index = 0
    local arr = nil

    if self.m_nFlag == 1 then
        if self.m_nIndex ==3 then
           
            index = self:randIndex(self.m_nLastIndex ,row)
            self.m_nLastIndex = index
        else
    
            index = math.random(row)
        end
    else
        arr =self:randInChallenge(self.m_nCurNomalIndex-2)
        if #arr == 2 then
            table.insert(self.m_arrFaCaiIndex,arr[1])
            table.insert(self.m_arrNotFaCaiIndex,arr[2])
        end
    end
  
    local color 

    local blockWidth  = (ScreenSize.width - GAME_BLOCK_WIDTH*(row-1))/row
    local blockHeight = (ScreenSize.height- GAME_BLOCK_WIDTH*(row-1))/row

    local originalRow = 0
    if self.m_nFlag == 1 then
        if self.m_nIndex~= 5 then
            originalRow = 1
        else
            originalRow = 2
        end 
    else
        originalRow = 2
    end

    local str = nil
    for i=1 ,row do
        if  lineCount == 0 then
            color =cc.c3b(255,255,255)
       
        elseif lineCount == originalRow then
            if self.m_nFlag == 2 then
                index = arr[1]
            end

            if i==index then
                str ="开始"
                color = cc.c3b(0,150,0)
            else
                str = nil
                color =cc.c3b(255,255,255)
            end

        elseif lineCount ~= originalRow then
            if self.m_nFlag == 1 then

                if lineCount == 1 and originalRow == 2 then
                    color = cc.c3b(255,255,255)
                else
                    if i == index then
                        color = cc.c3b(0,150,0)
                    else
                        color =cc.c3b(255,255,255)
                    end
                end

            elseif self.m_nFlag == 2 then
                if lineCount == 1 then
                    color = cc.c3b(255,255,255)
                else
                    for m,n in ipairs(arr) do
                        if n == i then
                           
                            color = cc.c3b(0,150,0)
                            break
                        else
                            color =cc.c3b(255,255,255)
                        end
                    end
                end
            end
 
        end

        local curC3b = cc.c3b(67,205,128)
        local block = CDBlockItem:createdBlockItem()
        block:createBlock(color,cc.size(blockWidth,blockHeight),str,30,curC3b)
       
        block:SetLineIndex(lineCount)
        block:setPosition(cc.p( ScreenSize.width-ScreenSize.width/row*(lineCount+1),ScreenSize.height/row*(i-1)))
        self.m_pNewLayerRoot:addChild(block)

        if not self.m_pBlockArr[self.m_nCurNomalIndex] then
            print("self.m_nCurNomalIndex---------------------->",self.m_nCurNomalIndex)
            self.m_pBlockArr[self.m_nCurNomalIndex] = {}
        end

        table.insert(self.m_pBlockArr[self.m_nCurNomalIndex],block)
    end
end

----------------------------------------------------------------------------
--不连续规则下使用
-- 记录上一次随机的位置
function CDLayerTable_CBK:randIndex(lastIndex,row)

    local selectArr = {1,2,3,4,5}
    local randNumTotal = row
    local pos = 0
    local  indexPos
    if lastIndex ~= 0 then
        table.remove(selectArr,lastIndex)

        pos = math.random(randNumTotal-1)
        indexPos  = selectArr[pos]
    else
        pos = math.random(randNumTotal)
        indexPos = pos
    end

    return indexPos
end

----------------------------------------------------------------------------
function CDLayerTable_CBK:startTimer()
    local time = os.clock()
    local function showTimeLabel()
      
        local offest = os.clock() - time
        local str  = string.format("%.3f",offest)
        self.m_pttf:setString(str)
        self.m_nRecordTime = offest
    end 

    if not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(showTimeLabel,0.1,false)
    end
end


function CDLayerTable_CBK:stopTimer( )

    if self.m_pttf then
        self.m_pttf:setVisible(false)
    end

    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)  
        print("self.m_nRecordTime--------->",self.m_nRecordTime) 
        self.schedulerID = nil
    end  
end


function CDLayerTable_CBK:showLastView()
    if self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(false)
    end

    self.m_bInTheGame = false
    self:stopAllActions()
    self.m_pLayerLastView:setVisible(true)

    if self.m_PEndSprite ~= nil then
        self.m_PEndSprite:removeFromParent()
        self.m_PEndSprite = nil
    end

    if self.m_pLabel~= nil then
        self.m_pLabel:removeFromParent()
        self.m_pLabel = nil
    end

    if self.m_pWinttf~= nil then
        self.m_pWinttf:removeFromParent()
        self.m_pWinttf = nil
    end

    if self.m_ptimeLabel ~= nil then
        self.m_ptimeLabel:removeFromParent()
        self.m_ptimeLabel = nil
    end

    
    local curPos = cc.p(130,270)
    local curAnchorPoint = cc.p(0.5,0.5)
    local textColor 
    --胜利
    if self.m_bIsWin then
        local index  = math.random(4)
        local SpriteStr = "win_"..index..".png"

        self.m_PEndSprite= self:createSprite(self.m_pNodeLastView,SpriteStr,curPos,curAnchorPoint,true)
        
        textColor = cc.c3b(250,0,0)
        curPos = cc.p(125,210)
        self.m_pLabel =  self:createLabel(self.m_pNodeLastView,"成 功 了 !",60,textColor,curPos)
       
    else--失败

        local index  = math.random(4)
        local SpriteStr = "lost_"..index..".png"


        self.m_PEndSprite= self:createSprite(self.m_pNodeLastView,SpriteStr,curPos,curAnchorPoint,true)
        if self.m_nFlag ~= 3 then
            textColor = cc.c3b(130,130,130)
            curPos = cc.p(130,210)
            self.m_pLabel =  self:createLabel(self.m_pNodeLastView,"失 败 了!",60,textColor,curPos)
        end
    end


    local str  = string.format("%.3f".."'' ",self.m_nRecordTime)
    textColor = cc.c3b(0,0,0)
    curPos = cc.p(130,135)

    if self.m_nFlag == 3 then
        curPos =  cc.p(130,190)
    end
    self.m_ptimeLabel = self:createLabel(self.m_pNodeLastView,str,80,textColor,curPos)

    self:recordTime()
    self.m_pWinttf = cc.LabelTTF:create("00.000","Courier New",42)
    self.m_pWinttf:setColor(cc.c3b(255,0,0))
    self.m_pWinttf:setLocalZOrder(100)
    if self.m_nFlag == 3 then
        self.m_pWinttf:setPosition(cc.p(130,90))
    else
        self.m_pWinttf:setPosition(cc.p(120,70))
    end
    self.m_pNodeLastView:addChild(self.m_pWinttf)
    if self.m_bIsWin then
        if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) < self.m_nRecordTime then
            self.m_pWinttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
        else
            self.m_pWinttf:setString("新纪录!")
        end
    else
        if self.m_nFlag == 3 then
            if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) == 0 then
                g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
                self.m_pWinttf:setString("新纪录!")
            else
                if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) > self.m_nRecordTime then
                    self.m_pWinttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
                else
                    g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
                    self.m_pWinttf:setString("新纪录!")
                end
            end
        else
            self.m_pWinttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
        end
    end
    
end

-- 重置电量
function CDLayerTable_CBK:resetPower()
    local function updatePower()
        local power = platform_help.getBatterLevel()
        if  power > 100 then
            power = 100
        elseif power < 0 then
            power = 0
        end
    
        local width = power * 0.01 * 33
        local size = self.m_pIcoPower:getContentSize()
        size.width = width
        self.m_pIcoPower:setContentSize(size)
        self.m_pIcoPower:runAction(cc.Sequence:create(cc.DelayTime:create(60.0), cc.CallFunc:create(updatePower)))
    end
    updatePower()
end

--=================================基本方法=================================--

--根据 模式 创建格子的数量
function CDLayerTable_CBK:getNumByFlag()
    if not self.m_nFlag then
        return 0
    end
    if self.m_nFlag == 1 then

        if self.m_nIndex == 1  then
            self.m_nRow = 4
            self.m_nNeedTouch =25
        elseif self.m_nIndex == 2 then
            self.m_nRow = 4
            self.m_nNeedTouch =50
        elseif self.m_nIndex == 3  or self.m_nIndex == 4 then
            self.m_nRow = 5
            self.m_nNeedTouch = 50
        elseif self.m_nIndex == 5 then
            self.m_nRow = 6
            self.m_nNeedTouch = 50
        else
            self.m_nNeedTouch = 25
            self.m_nRow=4
        end
    elseif self.m_nFlag == 2 then
        self.m_nRow = 6 
    elseif self.m_nFlag == 3 then

        if self.m_nIndex == 1 then
            self.m_nRow = 4
            self.m_nCurCheckIndex = 2 
        elseif self.m_nIndex == 2 or self.m_nIndex == 3 then
            self.m_nRow = 5
            self.m_nCurCheckIndex = 2
        else  
            self.m_nRow = 6
            self.m_nCurCheckIndex = 3 
        end
    end
end

--显示时间的label
function CDLayerTable_CBK:showTimeLabel()
    if not self.m_pttf then
        self.m_pttf = cc.LabelTTF:create("0.000","Courier New",50)
        self.m_pttf:setColor(cc.c3b(255,0,0))
        self.m_pttf:setRotation(-90)
        self.m_pttf:setZOrder(100)
        self.m_pttf:setPosition(cc.p(25,ScreenSize.height/2))
        self.m_pBlockLayer:addChild(self.m_pttf)
    end
end

function CDLayerTable_CBK:createMyBlock()

    if not self.m_pLayer1 then
        self.m_pLayer1 = cc.Layer:create()
        self.m_pLayer1:setAnchorPoint(cc.p(0,0))
        self.m_pLayer1:setPosition(cc.p(0,0))
        self.m_pNewLayerRoot:addChild(self.m_pLayer1)
    end
      
    local blockWidth  = (ScreenSize.width - GAME_BLOCK_WIDTH*(self.m_nRow-1))/self.m_nRow
    local blockHeight = (ScreenSize.height- GAME_BLOCK_WIDTH*(self.m_nRow-1))/self.m_nRow

    local color 
    local index = 0
    local curC3b = cc.c3b(67,205,128)
    local str = nil
    --预创建
    local curStrart = 3*self.m_nRow*(self.m_nCurCount-1)+1
    local curEnd = 3*self.m_nRow*self.m_nCurCount

    local startRow = 2 
    if self.m_nIndex == 4 then
        startRow = 3 
    end
 
    for i =curStrart ,curEnd do
        if not self.m_pBlockVec[i] then
            self.m_pBlockVec[i] = {}
        end

        if self.m_nIndex == 2 then
       
            index = self:randIndex(self.m_nLastIndex ,self.m_nRow)
            self.m_nLastIndex = index
        else
            index = math.random(self.m_nRow)
        end

        for j =1,self.m_nRow do

            if j == index then
                if i == startRow then
                    str = "开始"
                else
                    str = nil
                end
                color = cc.c3b(0,150,0)
            else
                str = nil

                color = cc.c3b(255,255,255)
            end
            -- 第一行不需要显示绿色
            if i == 1 then
                color = cc.c3b(255,255,255)
            end

            if startRow == 3 then
                if i == 2 then
                    color = cc.c3b(255,255,255)
                end
            end

            local block = CDBlockItem:createdBlockItem()
            block:createBlock(color,cc.size(blockWidth,blockHeight),str,30,curC3b)
            block:setPosition(cc.p(ScreenSize.width-ScreenSize.width/self.m_nRow*i,ScreenSize.height/self.m_nRow*(j-1)))
            
            self.m_pLayer1:addChild(block)
            table.insert(self.m_pBlockVec[i],block)
        end
    end
end

-- 创建用户界面
function CDLayerTable_CBK:createUserInterface(flag)
    cclog("CDLayerTable_CBK::createUserInterface")

    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    if not self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(true)
    end
    -- 经典模式 1  挑战模式 2  极速模式 3
    self.m_nFlag = flag
    self:getNumByFlag()
   
    self:showTimeLabel()
    --模式2 下 创建放置麻将的层
    if self.m_nFlag == 2 then
        if not self.m_pMahjongShowLayer then
            self.m_pMahjongShowLayer = cc.Layer:create()
            self.m_pMahjongShowLayer:setLocalZOrder(1000)
            self.m_pBlockLayer:addChild(self.m_pMahjongShowLayer)
        end
    end

    if not self.m_pBlockDemo then
        self.m_pBlockDemo = cc.LayerColor:create(cc.c3b(0,0,0),ScreenSize.width/5,ScreenSize.height)
        self.m_pBlockDemo:setAnchorPoint(cc.p(0,0))
        self.m_pBlockDemo:setPosition(cc.p(ScreenSize.width/5*4,0))
        self.m_pBlockLayer:addChild(self.m_pBlockDemo)
    end
   
    if self.m_nFlag == 3 then
        self:createMyBlock()
    else
        for i=0,self.m_nRow-1 do
            self:addNormalLineBlocks(i,self.m_nRow)
        end
    end
    self:addStartLine(1)
    self.m_bInTheGame = true
    -- 重置电量
    self:resetPower()
end

--重新开始游戏
function CDLayerTable_CBK:StartNextGame()
    self.m_bInTheGame = false
    local function setIsInTheGame()
       self.m_bInTheGame =true
    end 
    --为了点击再来一局而延迟
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(setIsInTheGame)))

    if self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pLayer1 = nil
    end

    if self.m_pMahjongShowLayer then
        self.m_pMahjongShowLayer:removeAllChildren()
    end  

    if not self.m_pttf:isVisible() then
        self.m_pttf:setString("0.000")
        self.m_pttf:setVisible(true)
    end

    if self.m_pBlockDemo and not self.m_pBlockDemo:isVisible() then
        self.m_pBlockDemo:setVisible(true)
    end

    if self.m_nFlag == 3 then
        self:createMyBlock()
    else
        for i=0,self.m_nRow-1 do
            self:addNormalLineBlocks(i,self.m_nRow)
        end
    end
    self:addStartLine(self.m_nIndex)
end


--用于重新开始时一些数据的清空
function CDLayerTable_CBK:clearData()

    if self.m_nFlag == 3 then
        self.m_nCurCount = 1 
        self.m_pBlockVec = {}
        if self.m_nIndex  ~= 4 then
            self.m_nCurCheckIndex = 2 
        else
            self.m_nCurCheckIndex = 3
        end
    end

    if self.m_nFlag == 2 then
        self.m_nTouchFaCai = 0
        self.m_arrFaCaiIndex = {}
        self.m_arrNotFaCaiIndex = {}
    end

    self.m_nRecordTime = 0 
    self.m_bTouchEndLine = false
    self.m_nTouchNum = 0
    self.m_nCurNomalIndex = 0
    self.m_pBlockArr = {}
    for i=1 ,DEF_MAX_ROW do
        self.m_pBlockArr[i] = {}
    end
end

---------------------------------------------------------------------------
function CDLayerTable_CBK:changeRuleAndView(index)
    if self.m_nIndex == index then
        return
    end
    
    self.m_nIndex = index
    self:getNumByFlag()

    for i,v in ipairs(self.m_pBlock) do
        v:setBlockColor(cc.c3b(255,255,0))
        v:setLabelColor(cc.c3b(0,0,0))
    end

    if self.m_pBlock[index] then
        self.m_pBlock[index]:setBlockColor(cc.c3b(0,0,0))
        self.m_pBlock[index]:setLabelColor(cc.c3b(255,255,255))
    end

    if self.m_nFlag ~= 3 then
        if self.m_pNewLayerRoot ~= nil then
            self.m_pNewLayerRoot:removeAllChildren()
        end
    else
        if self.m_pLayer1 ~= nil then
            self.m_pLayer1:removeAllChildren()
        end
    end
    
    --清空数组，便于存储
    if self.m_nFlag == 3 then
        self.m_pBlockVec = {}
        self:createMyBlock()
    else
        self.m_nCurNomalIndex = 0
        for i=1 ,DEF_MAX_ROW do
            self.m_pBlockArr[i] = {}
        end
    
        for i=0 ,self.m_nRow-1 do
            self:addNormalLineBlocks(i,self.m_nRow)
        end
    end
end

function CDLayerTable_CBK:cancelSchedule3()
   
    if  self.schedulerID3 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID3)   
        self.schedulerID3=nil
    end
end 
----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_CBK:init()
    cclog("CDLayerTable_CBK::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_CBK:onTouchBegan")

        -- 没有开始时，不能进行点击
        if not self.m_bInTheGame  or self.m_bIsTouchSetting then
            return
        end

        if not self.m_bTouchEndLine then
            if self.m_nFlag ~=2 then
                local sPoint = touch:getLocation()
                local rect 
                if self.m_pBlock[1] then
                     rect =self.m_pBlock[1]:getBoundingBox()
                end
        
                local index = 1
                if self.m_pBlock[1]:isVisible() then
                    if sPoint.x>ScreenSize.width- rect.width and sPoint.x < ScreenSize.width then
                        if sPoint.y < self.m_pBlock[1]:getPositionY()+rect.height then
                            index =1
                        elseif sPoint.y<self.m_pBlock[2]:getPositionY() +rect.height then
                            index =2
                        elseif sPoint.y<self.m_pBlock[3]:getPositionY() +rect.height then
                            index =3
                        elseif sPoint.y<self.m_pBlock[4]:getPositionY() +rect.height then
                            index =4
                        elseif sPoint.y<self.m_pBlock[5]:getPositionY() +rect.height then
                            index =5
                        end
                        
                        self:changeRuleAndView(index)
                        
                        if self.m_nFlag == 1  then
                            if self.m_nIndex~= 5 then
                                self.m_nTouchRow = 1
                            else
                                self.m_nTouchRow = 2
                            end
                        end
                        return
                    end 
                end
            else
                self.m_nTouchRow = 2
            end
        end

        local sPoint = touch:getLocation()
        local max_row = self.m_nCurNomalIndex

        if self.m_nFlag == 3 then
           
            local checkPosX =  ScreenSize.width
            local index = 0
            local speed = 8
            local function LayerMove()
                
                index = index +1 
                if index % 40 == 0 then
                    speed = speed + 1
                    print("speed---------->",speed)
                end

                local curX = self.m_nCurCheckIndex
                for j = 1 ,self.m_nRow do
                    
                    local pos = self.m_pBlockVec[curX][j]:convertToWorldSpace(cc.p(0,0))
                    local colorVec = self.m_pBlockVec[curX][j]:getColor()
                    if pos.x > checkPosX then
                       
                        if (colorVec.r ==0 and colorVec.g == 150 and colorVec.b==0) and  not self.m_pBlockVec[curX][j].m_bTouch then
                            local function showLast()
                                self.m_bIsWin = false
                                self:showLastView()
                            end 
                            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(showLast)))
                            self:stopTimer()
                            self:cancelSchedule3()

                            return
                        end
                        self.m_pBlockVec[curX][j]:removeFromParent()
                    end
                end

                if self.m_pLayer1:getPositionX() >= self.m_nCurCount *3 *(ScreenSize.width)/2 then
                    --再次创建
                    self.m_nCurCount = self.m_nCurCount +1
                    self:createMyBlock()
                end

                self.m_pLayer1:setPositionX(self.m_pLayer1:getPositionX()+speed)
            end

            local curIndex = self.m_nCurCheckIndex
            print("curIndex---------------->",curIndex)
           
            for j = 1 ,self.m_nRow do
                local rect = self.m_pBlockVec[curIndex][j]:getBoundingBox()
                local colorArr = self.m_pBlockVec[curIndex][j]:getColor()
                
                --转化坐标
                local  curPoint = self.m_pBlockVec[curIndex][j]:getParent():convertToNodeSpace(sPoint)  
                if cc.rectContainsPoint(rect,curPoint) then
                    
                    if self.m_pBlockDemo:isVisible() then
                        self.m_pBlockDemo:setVisible(false)
                    end

                    dtPlaySound(DEF_SOUND_CMJ)
                    if (colorArr.r ==0 and colorArr.g == 150 and colorArr.b==0) then
                        if self.m_pButSetting:isVisible() then
                            self.m_pButSetting:setVisible(false)
                        end
                        self.m_nCurCheckIndex = self.m_nCurCheckIndex +1 
                        
                        self.m_bTouchEndLine = true
                        self.m_pBlockVec[curIndex][j]:setTextBVisible(false)    
                        self.m_pBlockVec[curIndex][j].m_bTouch = true
                        self.m_pBlockVec[curIndex][j]:setBlockColor(cc.c3b(200,200,200))
                        if not self.schedulerID3 then
        
                            self.schedulerID3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(LayerMove,0.05,false)
                        end
                        self:startTimer()
                        return
                    else
                        self.m_bInTheGame = false
                        print("游戏结束")
                        local function showLast()
                            self.m_bIsWin = false
                            self:showLastView()
                        end 

                        self.m_pBlockVec[curIndex][j]:runAction(cc.Sequence:create(cc.CallFunc:create(self.m_pBlockVec[curIndex][j].setRedColor),cc.DelayTime:create(0.4),cc.CallFunc:create(self.m_pBlockVec[curIndex][j].clearBlockItem)))
                        self:cancelSchedule3()
                        self:stopTimer()
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(showLast)))
                        return
                    end
                end
            end
            
        else

            for i=max_row -self.m_nRow+1 ,max_row do
        
                for j =1 ,self.m_nRow do
                   
                    if  self.m_pBlockArr[i][j]._LineIndex ~= nil and self.m_pBlockArr[i][j]._LineIndex >-1 then

                        local rect = self.m_pBlockArr[i][j]:getBoundingBox()
                        local colorArr = self.m_pBlockArr[i][j]:getColor()
                        local curBlockIndex = self.m_pBlockArr[i][j]._LineIndex 


                        if cc.rectContainsPoint( rect, sPoint)  and  curBlockIndex == self.m_nTouchRow   then

                            dtPlaySound(DEF_SOUND_CMJ)
                            -- 最下方的一行不可见
                            if self.m_pBlockDemo:isVisible() then
                                self.m_pBlockDemo:setVisible(false)
                            end

                            if (colorArr.r ==0 and colorArr.g == 150 and colorArr.b==0) then
                       
                                self.m_pBlockArr[i][j]:setTextBVisible(false)
                                self.m_pBlockArr[i][j]:setBlockColor(cc.c3b(200,200,200))
                                self.m_bTouchEndLine = true

                               
                                self.m_nTouchNum   = self.m_nTouchNum +1
                                self:startTimer()
                               
                                if self.m_nFlag == 2 then
                                    if (i-2)%8 == 0 then
                                        local FaCaiIndex = (i-2)/8
                                        if self.m_arrFaCaiIndex[FaCaiIndex] == j then
                                    
                                            self.m_nTouchFaCai = self.m_nTouchFaCai +1

                                            self.m_pBlockArr[i][self.m_arrNotFaCaiIndex[FaCaiIndex]]:setBlockColor(cc.c3b(200,200,200))

                                            local mahjong =  CDMahjong.createCDMahjong(self.m_pMahjongShowLayer)
                                            mahjong:initMahjongWithFile("t_52.png")
                                            mahjong:setRotation(-90)
                                            mahjong:setPosition(cc.p(ScreenSize.width/3*2,ScreenSize.height/6*(j-1)))
                                            mahjong:runAction(cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(65,50+(self.m_nTouchFaCai-1)*108)),cc.ScaleTo:create(0.3,1.5,1.5)))
                                        else
                                            self.m_pBlockArr[i][self.m_arrFaCaiIndex[FaCaiIndex]]:setBlockColor(cc.c3b(200,200,200))
                                        end
                                    end
                                end

                                self:moveDown()

                                return
                            elseif (colorArr.r ==255 and colorArr.g == 255 and colorArr.b== 255) then

                                self.m_bInTheGame = false
                                local function showLast()
                                    self.m_bIsWin = false
                                    self:showLastView()
                                end 

                                self.m_pBlockArr[i][j]:runAction(cc.Sequence:create(cc.CallFunc:create(self.m_pBlockArr[i][j].setRedColor),cc.DelayTime:create(0.4),cc.CallFunc:create(self.m_pBlockArr[i][j].clearBlockItem)))
                                self:stopTimer()
                                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(showLast)))
                               
                                return
                            end
                        end
                    end
                    
                end
            end
        end

        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_CBK:onTouchMoved")
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_CBK:onTouchEnded")
    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end

-------------------------------------------------------------------------------

function CDLayerTable_CBK:blockMove()
    local row = self.m_nCurNomalIndex
    for i =row- self.m_nRow+1,row do
        for j=1 ,self.m_nRow do
            if self.m_pBlockArr[i][j]~= nil and self.m_pBlockArr[i][j]._LineIndex then
                self.m_pBlockArr[i][j]:moveDownAndCleanUp(self.m_nRow)
            end   
        end
    end

    if self.m_pEndLineBlock then
        self.m_pEndLineBlock:moveDownAndCleanUp(self.m_nRow)
    end
  
end

function CDLayerTable_CBK:moveDown()
    if self.m_nFlag == 1 then
        local compareTouchNum = 0
        if self.m_nIndex == 5 then
            compareTouchNum = self.m_nNeedTouch +2
        else
             compareTouchNum = self.m_nNeedTouch +1
        end
     
        if self.m_nTouchNum < self.m_nNeedTouch  then
            if self.m_nCurNomalIndex < compareTouchNum then
                self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
            else
                
                if not self.m_pEndLineBlock then
                    self.m_pEndLineBlock = CDBlockItem:createdBlockItem()
                    self.m_pEndLineBlock:createBlock(cc.c3b(67,205,128),ScreenSize)
                    self.m_pEndLineBlock:setPosition(cc.p(-ScreenSize.width,0))
                    self.m_pEndLineBlock:SetLineIndex(self.m_nRow)
                    self.m_pNewLayerRoot:addChild(self.m_pEndLineBlock)
                end

            end
        else
            local function showEndBlock()
                self.m_bIsWin = true
                self:addEndLineBlock()
            end 
           
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(showEndBlock)))
            self:blockMove()

            if self.m_nIndex == 5 then
                self:blockMove()
            end

            self:stopTimer()
        end
    else
        
        if self.m_nTouchFaCai < 2 then 
            self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
           
        else
            self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
            self:stopTimer()
            self:recordTime()

            local function showWinLastView()
                self.m_bIsWin = true
                self:showLastView()
            end 

            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(showWinLastView)))

        end
    end

    self:blockMove()
end
------------------------------------------------------------------------------
function CDLayerTable_CBK:showSound()

    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pSoundOpen:setVisible(music)
    self.m_pSoundClose:setVisible(not music)
    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_CBK:showMusic()

    local sound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not sound)

    self.m_pMusicOpen:setVisible(sound)
    self.m_pMusicClose:setVisible(not sound)
    dtPlaySound( DEF_SOUND_TOUCH)
end
--===============================界面函数绑定===============================
-- 设置
function CDLayerTable_CBK:onSetting()
    cclog( "CDLayerTable_CBK:onSetting")

    self.m_bIsTouchSetting = true
    local bMusic = g_pGlobalManagement:isEnableMusic()
    local bSound = g_pGlobalManagement:isEnableSound()

    self.m_pSoundOpen:setVisible(not bMusic)
    self.m_pSoundClose:setVisible(bMusic)

    self.m_pMusicOpen:setVisible(not bSound)
    self.m_pMusicClose:setVisible(bSound)
  
    if not self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(true)
    end
end

function CDLayerTable_CBK:onCloseSetting()
    if self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(false)
        self.m_bIsTouchSetting = false
    end
end

--返回大厅
function CDLayerTable_CBK:onGoToHall()
    if self.m_pLayerLastView:isVisible() or self.m_pSettingNode:isVisible() then
        self.m_pLayerLastView:setVisible(false)
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 
end

--重新开始
function CDLayerTable_CBK:onRestart()
    if self.m_pLayerLastView:isVisible() then
        self.m_pLayerLastView:setVisible(false)
        self:clearData()
        self:StartNextGame()
    end 
end
------------------------------------------------------
function CDLayerTable_CBK:onOpenSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundOpen:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_CBK:onCloseSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundClose:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_CBK:onOpenSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicOpen:isVisible() then
        self:showMusic()
    end
end

function CDLayerTable_CBK:onCloseSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicClose:isVisible() then
        self:showMusic()
    end
end
----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_CBK:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_CBK::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pGroupBar     = loader["group_bar"]
    self.m_pButSetting   = loader["but_setting"]
    self.m_pSelfInfo     = loader["self_info"]
    self.m_pTableInfo    = loader["table_info"]

    self.m_pNewLayerRoot    = loader["new_layer"]

    self.m_pBlockLayer     = loader["block_layer"]

    -- 电池
    self.m_pIcoPower        = loader["power"]
    self.m_pNewEffLayer     = loader["newEfflayer"]

    self.m_pSettingNode     = loader["setting_Node"]

    self.m_pSettingBtn = loader["but_setting"]

    self.m_pCloseBtn   = loader["btn_closeSetting"]

    ---------------------------------------------------
    self.m_pSoundOpen   = loader["sound_open"]
    self.m_pSoundClose  = loader["sound_close"]
    self.m_pMusicOpen   = loader["soundEffect_open"]
    self.m_pMusicClose  = loader["soundEffect_close"]

    self.m_pSoundOpenBtn  = loader["btn_sound"]
    self.m_pSoundCloseBtn = loader["btn_soundClose"]
    self.m_pMusicOpenBtn  = loader["btn_soundEffect"]
    self.m_pMusicCloseBtn = loader["btn_soundEffectClose"]
    ---------------------------------------------------
    --结束界面控件
    self.m_pLayerLastView  = loader["Layer_Lastview"]
    self.m_pNodeLastView   = loader["Node_LastView"]

    self.m_pBtnGoToHall   = loader["button_gotoHall"]
    self.m_pBtnRestart    = loader["button_restart"]
end
----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_CBK:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerTable_CBK::onResolveCCBCCControlSelector")
    
    -- 下方玩家功能区按钮
    loader["onSetting"]     = function() self:onSetting()  end         
       
    loader["onGoToHall"]    = function() self:onGoToHall() end

    loader["onRestart"]     = function() self:onRestart()  end

    loader["onSetting"]     = function() self:onSetting()  end
  
    loader["onCloseSetting"] =function() self:onCloseSetting() end


    loader["onOpenSound"] =  function () self:onOpenSound() end
  
    loader["onCloseSound"] = function () self:onCloseSound() end
 
    loader["onOpenSoundEffect"] = function () self:onOpenSoundEffect() end

    loader["onCloseSoundEffect"] = function () self:onCloseSoundEffect() end
    
end

----------------------------------------------------------------------------
-- create
function CDLayerTable_CBK.createCDLayerTable_CBK(pParent)
    cclog("CDLayerTable_CBK::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_CBK.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerTable_CBK.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end