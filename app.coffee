http = require 'http'
request = require 'request'
sugar = require 'sugar'
qs = require 'querystring'
key = process.env.KEY

app = http.createServer (req, resp) ->
  resp.writeHead 200, 'content-type': 'text/plain'
  resp.end "Weather Bot Up and Running!!!!\n"

app.listen process.env.VCAP_APP_PORT || 3000, -> console.log 'listening'

postResponse = (msg) ->
  [ city, state ] = msg.body.match(/^@weather-bot\s(.*)/)[1].split(', ')
  city = city.replace ' ', '%20'
  location = "#{state}/#{city}"
  console.log location
  request.get
    uri: 'http://api.wunderground.com/api/' + key + "/conditions/q/#{location}.json"
    json: true
    (e, resp, body) ->
      console.log body
      weather = body.current_observation.weather
      weather_image = body.current_observation.icon_url
      temperature_string = body.current_observation.temperature_string
      newmsg = 
        author: 'weather-bot'
        body: """
          <h3>#{weather}</h3>
          <h1>#{temperature_string}</h1>
          <img src='#{weather_image}' style="width:100%" />
          <hr />
          <small>Information provided by <a href="http://www.wunderground.com">Weather Underground</a></small>
        """
      # catch
      #   newmsg = author: 'weather-bot', body: "<img src='http://no-soup.jpg.to' />"
      #console.log newmsg
      request.post
        uri: 'http://catchat.wilbur.io/messages'
        json: newmsg
    
checkMessages = ->
  # future look for messages for me -> endpoint = 'http://catchat.wilbur.io/messages/image'
  endpoint = 'http://catchat.wilbur.io/messages'
  startkey = "?startkey=" + (10).secondBefore('now').iso()
  console.log "checking messages"
  request.get
    uri: endpoint + startkey
    json: true
    (err, resp, body) ->
      postResponse(msg) for msg in body when msg.body.match /^@weather-bot/

setInterval checkMessages, 10000

