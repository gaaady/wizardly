#
# GeneratedController class generated by wizardly_controller
#

class GeneratedController < ApplicationController
  before_filter :guard_entry

  
  # second action method
  def second
    begin
      @step = :second
      @wizard = wizard_config
      @title = 'Second'
      @description = ''
      h = (flash[:wizard_model]||{}).merge(params[:user] || {}) 
      @user = User.new(h)
      if request.post? && callback_performs_action?(:on_post_second_form)
        raise CallbackError, "render or redirect not allowed in :on_post_second_form callback", caller
      end
      button_id = check_action_for_button
      return if performed?
      if request.get?
        return if callback_performs_action?(:on_get_second_form)
        render_wizard_form
        return
      end

      # @user.enable_validation_group :second
      unless @user.valid?(:second)
        return if callback_performs_action?(:on_invalid_second_form)
        render_wizard_form
        return
      end

      if button_id == :finish
        return if callback_performs_action?(:on_second_form_finish)
        _on_wizard_finish if button_id == :finish
        redirect_to '/main/finished' unless self.performed?
        return
      end
      session[:progression].push(:second)
      return if callback_performs_action?(:on_second_form_next)
      redirect_to :action=>:finish
    ensure
      flash[:wizard_model] = h.merge(@user.attributes)    
    end
  end        


  # init action method
  def init
    begin
      @step = :init
      @wizard = wizard_config
      @title = 'Init'
      @description = ''
      h = (flash[:wizard_model]||{}).merge(params[:user] || {}) 
      @user = User.new(h)
      if request.post? && callback_performs_action?(:on_post_init_form)
        raise CallbackError, "render or redirect not allowed in :on_post_init_form callback", caller
      end
      button_id = check_action_for_button
      return if performed?
      if request.get?
        return if callback_performs_action?(:on_get_init_form)
        render_wizard_form
        return
      end

      # @user.enable_validation_group :init
      unless @user.valid?(:init)
        return if callback_performs_action?(:on_invalid_init_form)
        render_wizard_form
        return
      end

      if button_id == :finish
        return if callback_performs_action?(:on_init_form_finish)
        _on_wizard_finish if button_id == :finish
        redirect_to '/main/finished' unless self.performed?
        return
      end
      session[:progression] = [:init]
      return if callback_performs_action?(:on_init_form_next)
      redirect_to :action=>:second
    ensure
      flash[:wizard_model] = h.merge(@user.attributes)    
    end
  end        


  # finish action method
  def finish
    begin
      @step = :finish
      @wizard = wizard_config
      @title = 'Finish'
      @description = ''
      h = (flash[:wizard_model]||{}).merge(params[:user] || {}) 
      @user = User.new(h)
      if request.post? && callback_performs_action?(:on_post_finish_form)
        raise CallbackError, "render or redirect not allowed in :on_post_finish_form callback", caller
      end
      button_id = check_action_for_button
      return if performed?
      if request.get?
        return if callback_performs_action?(:on_get_finish_form)
        render_wizard_form
        return
      end

      # @user.enable_validation_group :finish
      unless @user.valid?(:finish)
        return if callback_performs_action?(:on_invalid_finish_form)
        render_wizard_form
        return
      end

      return if callback_performs_action?(:on_finish_form_finish)
      _on_wizard_finish
      redirect_to '/main/finished' unless self.performed?
    ensure
      flash[:wizard_model] = h.merge(@user.attributes)    
    end
  end        

  def index
    redirect_to :action=>:init
  end


    protected
  def _on_wizard_finish
    @user.save_without_validation!
    _wizard_final_redirect_to(:completed)
  end
  def _on_wizard_skip
    redirect_to(:action=>wizard_config.next_page(@step)) unless self.performed?
  end
  def _on_wizard_back
    # TODO: fix progression management
    redirect_to(:action=>((session[:progression]||[]).pop || :init)) unless self.performed?
  end
  def _on_wizard_cancel
    _wizard_final_redirect_to(:canceled)
  end
  def _wizard_final_redirect_to(which_redirect) 
    flash.discard(:wizard_model)
    initial_referer = reset_wizard_session_vars
    unless self.performed?
      redir = (which_redirect == :completed ? wizard_config.completed_redirect : wizard_config.canceled_redirect) || initial_referer
      return redirect_to(redir) if redir
      raise Wizardly::RedirectNotDefinedError, "No redirect was defined for completion or canceling the wizard.  Use :completed and :canceled options to define redirects.", caller
    end
  end
  hide_action :_on_wizard_finish, :_on_wizard_skip, :_on_wizard_back, :_on_wizard_cancel, :_wizard_final_redirect_to


    protected
  def guard_entry
    if (r = request.env['HTTP_REFERER'])
      h = ::ActionController::Routing::Routes.recognize_path(URI.parse(r).path)
      return if (h[:controller]||'') == 'generated'
      session[:initial_referer] = h
    else
      session[:initial_referer] = nil
    end
    flash.discard(:wizard_model)
    
    redirect_to :action=>:init unless (params[:action] || '') == 'init'
  end   
  hide_action :guard_entry

  def render_wizard_form
  end
  hide_action :render_wizard_form

  def performed?; super; end
  hide_action :performed?

  def check_action_for_button
    button_id = nil
    #check if params[:commit] has returned a button from submit_tag
    unless (params[:commit] == nil)
      button_name = methodize_button_name(params[:commit])
      unless [:next, :finish].include?(button_id = button_name.to_sym)
        action_method_name = "on_" + params[:action].to_s + "_form_" + button_name
        callback_performs_action?(action_method_name)
        method_name = "_on_wizard_" + button_name
        if (self.method(method_name))
          self.__send__(method_name)
        else
          raise MissingCallbackError, "Callback method either '" + action_method_name + "' or '" + method_name + "' not defined", caller
        end
      end
    end
    #add other checks here or above
    button_id
  end
  hide_action :check_action_for_button

  @wizard_callbacks ||= {}
  class << self
    attr_reader :wizard_callbacks
  end
  
  def callback_performs_action?(methId, arg=nil)
    return false unless self.methods.include?(methId.to_s)
    #self.__send__(methId)
    self.method(methId).call
    self.performed?
  end
  hide_action :callback_performs_action?



    def self.on_post(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_post is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_post_%s_form", form.to_s), &block )
    end
  end
  def self.on_get(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_get is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_get_%s_form", form.to_s), &block )
    end
  end
  def self.on_errors(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_errors is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_invalid_%s_form", form.to_s), &block )
    end
  end
  def self.on_back(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_back is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_%s_form_back", form.to_s), &block )
    end
  end
  def self.on_cancel(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_cancel is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_%s_form_cancel", form.to_s), &block )
    end
  end
  def self.on_skip(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_skip is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_%s_form_skip", form.to_s), &block )
    end
  end
  def self.on_finish(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_finish is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_%s_form_finish", form.to_s), &block )
    end
  end
  def self.on_next(*args, &block)
    return if args.empty?
    all_forms = [:init, :second, :finish]
    if args.include?(:all)
      forms = all_forms
    else
      forms = args.map do |fa|
        unless all_forms.include?(fa)
          raise(ArgumentError, ":"+fa.to_s+" in callback on_next is not a form defined for the wizard", caller)
        end
        fa
      end
    end
    forms.each do |form|
      self.send(:define_method, sprintf("on_%s_form_next", form.to_s), &block )
    end
  end


  private
  def methodize_button_name(value)
    value.to_s.strip.squeeze(' ').gsub(/ /, '_').downcase
  end

  def reset_wizard_session_vars
    session[:progression] = nil
    init = session[:initial_referer]
    session[:initial_referer] = nil
    init
  end
  hide_action :methodize_button_name, :reset_wizard_session_vars

  public
  def wizard_config; self.class.wizard_config; end
  hide_action :wizard_config
  
  private

  def self.wizard_config; @wizard_config; end
  @wizard_config = Wizardly::Wizard::Configuration.create(:generated, :user, :allow_skip=>true) do
    when_completed_redirect_to '/main/finished'
    when_canceled_redirect_to '/main/canceled'
    
    # other things you can configure
    # change_button(:next).to('Next One')
    # change_button(:back).to('Previous')
    # create_button('Help')
    # set_page(:init).buttons_to :next_one, :previous, :cancel, :help #this removes skip
  end

end
