require 'houston'
require 'securerandom'

class APNConnection
  class InvalidDeviceTokenError < StandardError; end
  class RetryError < StandardError; end
  class Error < StandardError; end


  URI = "apn://localhost:7777"

  CERT = File.read("apple_push_notification.pem")

  def initialize
    @shutting_down = false
    puts "[APN_Connection] Initializing #{self.inspect}"
    @connection = Houston::Connection.new(URI, CERT, nil)
  end

  def open
    puts "[APN_Connection] Opening APN connection"
    @connection.open
    puts "[APN_Connection] Cannot connect" unless @connection.open?
  end

  def close
    puts "[APN_Connection] Closing APN connection"
    @connection.close
  end

  def reopen_connection
    close
    open
  end

  def connection
    @connection
  end

  def shutdown!
    @shutting_down = true
  end

  def write(notification)
    puts "[APN_Connection] Notification details: #{notification.inspect}"

    open unless @connection.open?
    raise "Process is shutting down" if @shutting_down

    @connection.write(notification.message)

    read_socket, write_socket = IO.select([@connection.ssl], nil, [@connection.ssl], 0.3)

    puts "[APN_Connection] Read socket #{notification.token}"
    puts "[APN_Connection] #{read_socket.inspect}"
    if (read_socket && read_socket[0])
      notification.mark_as_unsent!

      error = connection.read(6)
      command, status, identifier = error.unpack("ccN") if error

      puts "[APN_Connection] APN error status: #{status}"

      reopen_connection

      case status
      when 8
        raise InvalidDeviceTokenError, "identifier: #{identifier}"
      when 0, 1, 10, 255
        raise RetryError, "identifier: #{identifier}"
      else
        raise Error, "identifier: #{identifier}, status: #{status}"
      end
    end

    notification.mark_as_sent!
    notification
  rescue Errno::ECONNABORTED, Errno::EPIPE, Errno::ECONNRESET, Errno::EBADF, OpenSSL::SSL::SSLError => e
    reopen_connection
    raise
  end

end


# apns = APNConnection.new
apns = Houston::Client.new
apns.gateway_uri = APNConnection::URI
apns.certificate = APNConnection::CERT

# An example of the token sent back when a device registers for notifications


notifications = 10_000.times.map do |i|
  token = SecureRandom.hex(32) #"fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2"

  notification = Houston::Notification.new(device: token)
  notification.alert = "Hello, World!"
  notification.badge = 1  #
  notification.sound = "sosumi.aiff"
  notification.content_available = true
  notification.custom_data = {foo: "bar"}
  notification.expiry = Time.now.to_i + 25
  notification.priority = 10
  notification
end

apns.push(notifications)
