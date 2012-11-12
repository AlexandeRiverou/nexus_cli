module NexusCli
  # @author Kyle Allan <kallan@riotgames.com>
  module UsersMixin
    def get_users
      response = nexus.get(nexus_url("service/local/users"))
      case response.status
      when 200
        return response.content
      else
        raise UnexpectedStatusCodeException.new(response.status)
      end
    end

    def create_user(params)
      response = nexus.post(nexus_url("service/local/users"), :body => create_user_json(params), :header => DEFAULT_CONTENT_TYPE_HEADER)
      case response.status
      when 201
        return true
      when 400
        raise CreateUserException.new(response.content)
      else
        raise UnexpectedStatusCodeException.new(reponse.code)
      end
    end

    def update_user(params)
      params[:roles] = [] if params[:roles] == [""]
      user_json = get_user(params[:userId])

      modified_json = JsonPath.for(user_json)
      params.each do |key, value|
        modified_json.gsub!("$..#{key}"){|v| value} unless key == "userId" || value.blank?
      end

      response = nexus.put(nexus_url("service/local/users/#{params[:userId]}"), :body => JSON.dump(modified_json.to_hash), :header => DEFAULT_CONTENT_TYPE_HEADER)
      case response.status
      when 200
        return true
      when 400
        raise UpdateUserException.new(response.content)
      else
        raise UnexpectedStatusCodeException.new(response.status)
      end
    end

    def get_user(user)
      response = nexus.get(nexus_url("service/local/users/#{user}"), :header => DEFAULT_ACCEPT_HEADER)
      case response.status
      when 200
        return JSON.parse(response.content)
      when 404
        raise UserNotFoundException.new(user)
      else
        raise UnexpectedStatusCodeException.new(response.status)
      end
    end

    # Changes the password of a user
    # 
    # @param  params [Hash] a hash given to update the users password
    # 
    # @return [type] [description]
    def change_password(params)
      response = nexus.post(nexus_url("service/local/users_changepw"), :body => create_change_password_json(params), :header => DEFAULT_CONTENT_TYPE_HEADER)
      case response.status
      when 202
        return true
      when 400
        raise InvalidCredentialsException
      else
        raise UnexpectedStatusCodeException.new(response.status)
      end
    end

    def delete_user(user_id)
      response = nexus.delete(nexus_url("service/local/users/#{user_id}"))
      case response.status
      when 204
        return true
      when 404
        raise UserNotFoundException.new(user_id)
      else
        raise UnexpectedStatusCodeException.new(response.status)
      end
    end
  end
end