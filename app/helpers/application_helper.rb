module ApplicationHelper

  def logo
    image_tag("rails.png", :alt => "Logo", :class => "logo")#,  :size => "246x82")
  end

  def authenticate_api
    if !cookies.signed[:remember_auth].nil?
      @selected_auth = cookies.signed[:remember_auth][0] || nil
    end
    if @selected_auth.nil?
      puts "selected null"
      @selected_auth=Auth.all.first.id
    end
    auth = Auth.find_by_id(@selected_auth)
    puts "selected = #{@selected_auth}"
    Basecamp.establish_connection!(auth.domain, auth.token, 'X', true)
  end

#  'schoolscloud.basecamphq.com'
#  '1697eb4b12d8cd2e37cf14129839ac6e4e035d3c'
#  'dc84564d1f0a05376b00186d62a751ae75d722bb'
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :per_page => params[:per_page]}, {:class => css_class}
  end
  
  def start_session
    if !@session
      @auths = Auth.all
      @session = true
    end
  end
  
  def get_actions(msg)
    sentences = Sentence.get_sentences(msg)
    actions = []
    action_words = Word.find_all_by_word_type('action')
    strip_words = Word.find_all_by_word_type('strip')
    sentences.each do |s|
      s.strip(strip_words)
      if s.is_word_type?(action_words)
        actions << "#{s.to_str}"
      end
    end
    actions
  end  
  
  def get_events(msg)
    sentences = Sentence.get_sentences(msg)
    if sentences.nil?
      return []
    end
    events = []
    event_words = Word.find_all_by_word_type('event')
    sentences.each do |s|
      if s.is_word_type?(event_words)
        events << "#{s.to_str}"
      end
    end
    events
  end    
end
