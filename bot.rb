require 'slack-ruby-client'
require 'figaro'
require 'httparty'

def figaro_init
  Figaro.application = Figaro::Application.new(environment: 'production', path: 'config/application.yml')
  Figaro.load
  Figaro.require_keys('SLACK_API_TOKEN')
end

def slack_init
  Slack.configure { |config| config.token = ENV['SLACK_API_TOKEN'] }
end

def create_ticket(name, topic, msg_data)
    if topic == ''
        @real_time_client.message(channel: msg_data['channel'], text: 'You need to enter a topic! Please see `.ticket help` for more information.')
        return false
    end

    url = "#{ENV['HELPQ_URL']}/createTicket"

    options = {
        query: {
            apiKey: ENV['HELPQ_API_KEY'],
            name: name,
            topic: topic
        }
    }

    resp = HTTParty.get(url, options)

    return handle_error(name, resp, msg_data) unless resp.code == 200

    msg = 'Your ticket has been created! A mentor will be with you shortly.'
    @real_time_client.message(channel: msg_data['channel'], text: msg)

    puts "Successful create for #{name}: #{resp.body}"

    return true
end

def delete_ticket(name, msg_data)
    url = "#{ENV['HELPQ_URL']}/deleteTicket"

    options = {
        query: {
            apiKey: ENV['HELPQ_API_KEY'],
            name: name
        }
    }

    resp = HTTParty.get(url, options)

    return handle_error(name, resp, msg_data) unless resp.code == 200

    msg = 'Your ticket has been successfully deleted.'
    @real_time_client.message(channel: msg_data['channel'], text: msg)

    puts "Successful delete for #{name}: #{resp.body}"

    return true
end

def get_ticket(name, msg_data)
    url = "#{ENV['HELPQ_URL']}/getTicket"

    options = {
        query: {
            apiKey: ENV['HELPQ_API_KEY'],
            name: name
        }
    }

    resp = HTTParty.get(url, options)

    return handle_error(name, resp, msg_data) unless resp.code == 200

    resp_obj = JSON::parse(resp.body)

    msg = "Found a ticket for \"#{resp_obj['ticket']['topic']}\" with a status of #{resp_obj['ticket']['status']}."
    @real_time_client.message(channel: msg_data['channel'], text: msg)

    puts "Successful get for #{name}: #{resp_obj}"

    return true
end

def handle_error(name, resp, msg_data)
    # Parse response to verify errors
    resp_obj = JSON::parse(resp.body)

    # DEBUG
    puts "#{resp_obj}"

    # Default error message.
    msg = 'An error occured. Please contact an admin.'

    # Unauthorized; wrong API key.
    if resp.code == 401
        msg = 'The API key is incorrect. Please contact an admin.'
    end

    # Missing a parameter; either topic or name.
    if resp.code == 400 && resp_obj['error'] == 'missing_param'
        msg = "#{resp_obj['msg']}. Please contact an admin."
    end

    # Already have a ticket open! Need to consult help.
    if resp.code == 400 && resp_obj['error'] == 'open_ticket'
        msg = 'You already have a ticket open! Please use `.ticket help` for available options.'
    end

    # No ticket found.
    if resp.code == 404 && resp_obj['error'] == 'no_ticket'
        msg = 'You currently do not have any open tickets. Please create one with `.ticket create [topic]`.'
    end

    # Some sort of server error...
    if resp.code == 500
        msg = resp_obj['msg']
    end

    @real_time_client.message(channel: msg_data['channel'], text: msg)

    # Puts the error
    puts "ERROR occured for #{name}: #{msg} // #{resp_obj}"

    return false
end

def help(msg_data)
    help_text = %q(
        This bot is fairly easy to use. You have the following commands:
        - `.ticket create [topic]`: creates a ticket for mentors to see
        - `.ticket delete`: deletes your ticket
        - `.ticket get`: fetches your open ticket
        - `.ticket [anything-else]`: fetches your open ticket
    )
    @real_time_client.message(channel: msg_data['channel'], text: help_text)
    return true
end


figaro_init
slack_init

client = Slack::Web::Client.new
@real_time_client = Slack::RealTime::Client.new

@real_time_client.on :hello do
  puts "Successfully connected, welcome '#{@real_time_client.self['name']}' to the '#{@real_time_client.team['name']}' team at https://#{@real_time_client.team['domain']}.slack.com."
end

@real_time_client.on :message do |data|
  # Match on `.ticket`
  if /(^\.ticket)(.*)/.match(data['text'])
    # Determine the command.
    command = data['text'].gsub(/^.ticket/, '').strip

    # Determine name from user.
    name = client.users_info(user: data['user'])['user']['name']

    # Need to check if we're creating a ticket.
    if /(^create)(.*)/.match(command)
        topic = command.gsub(/^create/, '').strip
        create_ticket(name, topic, data)
        next
    end

    case command
    when 'get'
        get_ticket(name, data)
    when 'delete'
        delete_ticket(name, data)
    when 'help'
        help(data)
    else
        # Assume anyone else is looking to get their ticket status...
        get_ticket(name, data)
    end
  end
end

@real_time_client.start!
