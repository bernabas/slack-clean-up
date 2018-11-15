require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new
client.chat_postMessage(channel: '#general', text: 'big boy data', as_user: false)

pages = client.files_list.paging.pages

def list_all_users(client)
  h = {}

  client.users_list.members.each do |user|
    h[user.id] = user
  end

  h
end

def images_by_user(client, pages)
  h = {}

  pages.times do |_|
    list = client.files_list
    list.files.each do |file|
      h[file.user] ||= []
      h[file.user] << file
    end
  end

  return h
end

users = list_all_users(client)
images = images_by_user(client, pages)

users.each do |key, value|
  client.chat_postMessage(channel: '#general', text: "#{value.name} => uploaded #{images[key]&.size || 0}", as_user: false)
end
