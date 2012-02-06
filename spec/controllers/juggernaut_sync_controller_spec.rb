# Copyright (C) 2009 Cognifide
# 
# This file is part of Taskboard.
# 
# Taskboard is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Taskboard is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Taskboard. If not, see <http://www.gnu.org/licenses/>.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JuggernautSyncController do

  it "should synchronize changing name of the taskboard" do
    taskboard = Taskboard.new
    taskboard.id = 3
    Juggernaut.should_receive(:publish).with(3, /sync\.renameTaskboard.*/)
    
    controller.sync_rename_taskboard(taskboard).should include("success")
  end

end

describe JuggernautSyncController, "while dealing with column actions" do

  it "should synchronize adding a column" do
    column = Column.new
    column.taskboard_id = 43
    Juggernaut.should_receive(:publish).with(43, /sync\.addColumn.*/)
    
    controller.sync_add_column(column).should include("success")
  end

#	renameColumn
  it "should synchronize renaming a column" do
    column = Column.new
    column.taskboard_id = 12
    Juggernaut.should_receive(:publish).with(12, /sync\.renameColumn.*/)
    
    controller.sync_rename_column(column).should include("success")
  end

#	moveColumn
  it "should synchronize moving a column" do
    column = Column.new
    column.taskboard_id = 23
    Juggernaut.should_receive(:publish).with(23, /sync\.moveColumn.*/)
    
    controller.sync_move_column(column).should include("success")
  end

#	deleteColumn
  it "should synchronize deleting a column" do
    column = Column.new
    column.taskboard_id = 83
    Juggernaut.should_receive(:publish).with(83, /sync\.deleteColumn.*/)
    
    controller.sync_delete_column(column).should include("success")
  end

end

describe JuggernautSyncController, "while dealing with cards actions" do

  it "should synchronize adding cards" do
    card = Card.new
    card.taskboard_id = 42
    Juggernaut.should_receive(:publish).with(42, /sync\.addCards.*/)
    
    controller.sync_add_cards([card]).should include("success")
  end

  it "should synchronize moving a card" do    
    card = Card.new
    card.taskboard_id = 98
    card.column = Column.new
    Juggernaut.should_receive(:publish).with(98, /sync\.moveCard.*/)
    
    controller.sync_move_card(card).should include("success")
  end

  it "should synchronize updating ideal hours on a card" do
    card = Card.new
    card.taskboard_id = 98
    Juggernaut.should_receive(:publish).with(98, /sync\.updateCardHours.*/)
    
    controller.sync_update_card_hours(card).should include("success")
  end

  it "should synchronize changing card color" do
    card = Card.new
    card.taskboard_id = 74
    Juggernaut.should_receive(:publish).with(74, /sync\.changeCardColor.*/)
    
    controller.sync_change_card_color(card).should include("success")
  end

  it "should synchronize deleting a card" do
    card = Card.new
    card.taskboard_id = 83
    Juggernaut.should_receive(:publish).with(83, /sync\.deleteCard.*/)
    
    controller.sync_delete_card(card).should include("success")
  end

end

describe JuggernautSyncController, "while saving report" do

  before(:each) do
    @params = { :message => "test message", :before => "dummy before value" }

    @taskboard = Taskboard.new
    @taskboard.id = 82
    @taskboard.name = "Test taskboard"
    
    @column = Column.new
    @column.id = 64
    @column.taskboard_id = @taskboard.id
    @column.position = 1
    
    @card = Card.new
    @card.id = 46    
    @card.taskboard_id = @taskboard.id
    @card.column_id = @column.id
    @card.column = @column
    @card.position = 1
    
    Juggernaut.should_receive(:publish)
  end
    
  context "of taskboard actions" do
  
    it "should report that taskboard was renamed" do
      controller.should_receive(:report).with(@taskboard.id, 'renameTaskboard', @params[:message],
                                              hash_including(:object_id => @taskboard.id,
                                                             :object_name => @taskboard.name,
                                                             :before => @params[:before],
                                                             :after => @taskboard.name) )
      controller.sync_rename_taskboard @taskboard, @params
    end
    
  end
  
  context "of column actions" do
    
    it "should report that column was added" do
      controller.should_receive(:report).with(@taskboard.id, 'addColumn', @params[:message],
                                              hash_including(:object_id => @column.id,
                                                             :object_name => @column.name,
                                                             :before => @params[:before]) )
      controller.sync_add_column @column, @params
    end

    it "should report that column was renamed" do
      controller.should_receive(:report).with(@taskboard.id, 'renameColumn', @params[:message],
                                              hash_including(:object_id => @column.id,
                                                             :object_name => @column.name,
                                                             :before => @params[:before],
                                                             :after => @column.name) )
      controller.sync_rename_column @column, @params
    end

    it "should report that column was moved" do
      controller.should_receive(:report).with(@taskboard.id, 'moveColumn', @params[:message],
                                              hash_including(:object_id => @column.id,
                                                             :object_name => @column.name,
                                                             :before => @params[:before],
                                                             :after => @column.position) )
      controller.sync_move_column @column, @params
    end


    it "should report that column was deleted" do
      controller.should_receive(:report).with(@taskboard.id, 'deleteColumn', @params[:message],
                                              hash_including(:object_id => @column.id,
                                                             :object_name => @column.name,
                                                             :before => @params[:before]) )
      controller.sync_delete_column @column, @params
    end
    
  end
  
  context "of card actions" do
  
    it "should report that cards where added" do
      controller.should_receive(:report).with(@taskboard.id, 'addCards', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_add_cards [@card], @params
    end

    it "should report that card was moved" do
      controller.should_receive(:report).with(@taskboard.id, 'moveCard', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_move_card @card, @params
    end

    it "should report that ideal hours have been updated" do
      controller.should_receive(:report).with(@taskboard.id, 'updateCardHours', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_update_card_hours @card, @params
    end

    it "should report that card colour was changed" do
      controller.should_receive(:report).with(@taskboard.id, 'changeCardColor', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_change_card_color @card, @params
    end

    it "should report that card was deleted" do
      controller.should_receive(:report).with(@taskboard.id, 'deleteCard', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_delete_card @card, @params
    end

    it "should report that card was updated" do
      controller.should_receive(:report).with(@taskboard.id, 'updateCard', @params[:message],
                                              hash_including(:before => @params[:before]) )
      controller.sync_update_card @card, @params
    end  
    
  end
end
