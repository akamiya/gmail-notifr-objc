#
#  AccountDetailController.rb
#  Gmail Notifr
#
#  Created by James Chen on 8/19/09.
#  Copyright (c) 2009 ashchan.com. All rights reserved.
#

require 'osx/cocoa'

class AccountDetailController < OSX::NSWindowController
  
  ib_outlet :username
  ib_outlet :password
  ib_outlet :interval
  ib_outlet :accountEnabled
  ib_outlet :growl
  ib_outlet :soundList
  
  ib_action :soundSelect
  ib_action :cancel
  ib_action :okay
  
  def self.editAccountOnWindow(account, parentWindow)
    controller = alloc.initWithAccount(account)
    NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
      controller.window,
      parentWindow,
      controller,
      "sheetDidEnd_returnCode_contextInfo",
      nil
    )
  end
  
  def initWithAccount(account)
    initWithWindowNibName("AccountDetail")
    @account = account
    self
  end
  
  def awakeFromNib
  	@soundList.removeAllItems
    GNSound.all.each { |s| @soundList.addItemWithTitle(s) }
		@soundList.selectItemWithTitle(@account.sound)
 		@interval.setTitleWithMnemonic(@account.interval.to_s)
    @accountEnabled.setState(@account.enabled? ? NSOnState : NSOffState)
		@growl.setState(@account.growl ? NSOnState : NSOffState)
    @username.setTitleWithMnemonic(@account.username)
    @password.setTitleWithMnemonic(@account.password)
  end
  
  def cancel(sender)
    closeWindow
  end
  
  def okay(sender)
		@account.sound = @soundList.titleOfSelectedItem
  	@account.interval = @interval.integerValue
    @account.enabled = @accountEnabled.state == NSOnState ? true : false
		@account.growl = @growl.state == NSOnState ? true : false
    @account.username = @username.stringValue
    @account.password = @password.stringValue
    @account.save
    
    closeWindow
  end
  
  def soundSelect(sender)
		if sound = NSSound.soundNamed(@soundList.titleOfSelectedItem)
			sound.play
		end
	end
  
  def sheetDidEnd_returnCode_contextInfo(sheet, code, info)
    sheet.orderOut(nil)
  end

  private
  def closeWindow
    NSApp.endSheet(window)
  end
end