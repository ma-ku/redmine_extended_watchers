require_dependency 'watchers_controller'

module ExtendedWatchersControllerPatch
    
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :autocomplete_for_user, :extwatch
        end
    end

    module InstanceMethods

        def response_for_extunwatch

          url = url_for(:controller => :issues, :action => :index)
          respond_to do |format|
            format.js { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          end
          false
        end

        def check_project_privacy
          if (params[:action] == 'unwatch') && (params[:object_type] == 'issue')
            if User.current.logged?
              issue = Issue.find(params[:object_id])
              return issue.watched_by?(User.current)
            end
          end
          super()
        end

        def autocomplete_for_user_with_extwatch
	  @users = User.logged.status(1)
          @users = @users.sort  # @project.users.sort
#          @users.reject! {|user| !user.allowed_to?(:view_issues, @project)}
          if @watched
            @users -= @watched.watcher_users
          end

          render :layout => false
        end

    end

end

