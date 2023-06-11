module ActiveAdmin::ChannelsHelper #camelized file name
  def setup_search_form(builder)
    builder.grouping_fields builder.object.new_grouping,
      object_name: "new_object_name", child_index: "new_grouping" do |f|
      render("grouping_fields", f: f)
    end
  end

  def button_to_remove_fields
    tag.button "Remove", class: "remove_fields"
  end

  def button_to_add_fields(f, type)
    new_object, name = f.object.send("build_#{type}"), "#{type}_fields"
    fields = f.send(name, new_object, child_index: "new_#{type}") do |builder|
      render(name, f: builder)
    end

    tag.button button_label[type], class: "add_fields", 'data-field-type': type,
      'data-content': "#{fields}"
  end

  def button_to_nest_fields(type)
    tag.button button_label[type], class: "nest_fields", 'data-field-type': type
  end

  def button_label
    { value:     "Add Value",
      condition: "Add Condition",
      sort:      "Add Sort",
      grouping:  "Add Condition Group" }.freeze
  end

  def condition_fields
    %w(fields condition).freeze
  end

  def value_fields
    %w(fields value).freeze
  end

  def correct_name(name)
    "channel#{name.gsub('q[', '[q][')}"
  end
end