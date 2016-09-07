class ImageMailer < ApplicationMailer
  def send_share_email(email_address, message, url)
    @message = message
    @url = url

    mail(to: email_address, from: 'donotreply@appfolio.com', subject: 'Image Shared from Image-Sharer!')
  end
end
