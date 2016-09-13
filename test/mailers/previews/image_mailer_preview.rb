# Preview all emails at http://localhost:3000/rails/mailers/image_mailer
class ImageMailerPreview < ActionMailer::Preview
  def send_share_email
    ImageMailer.send_share_email(email_address: 'me@example.com',
                                 message: 'Hello!',
                                 url: 'https://isexample.com/image.png')
  end
end
