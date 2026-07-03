# user.getTopTracks

# Get the top tracks listened to by a user. You can stipulate a time period. Sends the overall chart by default.
# Example URLs

# JSON: /2.0/?method=user.gettoptracks&user=rj&api_key=YOUR_API_KEY&format=json
# XML: /2.0/?method=user.gettoptracks&user=rj&api_key=YOUR_API_KEY
# Params

# user (Required) : The user name to fetch top tracks for.
# period (Optional) : overall | 7day | 1month | 3month | 6month | 12month - The time period over which to retrieve top tracks for.
# limit (Optional) : The number of results to fetch per page. Defaults to 50.
# page (Optional) : The page number to fetch. Defaults to first page.
# api_key (Required) : A Last.fm API key.
#
# Error Codes
# 2 : Invalid service - This service does not exist
# 3 : Invalid Method - No method with that name in this package
# 4 : Authentication Failed - You do not have permissions to access the service
# 5 : Invalid format - This service doesn't exist in that format
# 6 : Invalid parameters - Your request is missing a required parameter
# 7 : Invalid resource specified
# 8 : Operation failed - Something else went wrong
# 9 : Invalid session key - Please re-authenticate
# 10 : Invalid API key - You must be granted a valid key by last.fm
# 11 : Service Offline - This service is temporarily offline. Try again later.
# 13 : Invalid method signature supplied
# 16 : There was a temporary error processing your request. Please try again
# 26 : Suspended API key - Access for your account has been suspended, please contact Last.fm
# 29 : Rate limit exceeded - Your IP has made too many requests in a short period
#

defmodule Autumnhoerr.Integrations.Lastfm do
  @moduledoc """
  This module provides integration with the Last.fm API.
  """
end
