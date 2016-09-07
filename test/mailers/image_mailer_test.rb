require 'test_helper'

class ImageMailerTest < ActionMailer::TestCase
  test 'test share email functionality' do
    email = ImageMailer.send_share_email('me@example.com', 'Hello!', 'https://isexample.com/image.png')

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['me@example.com'], email.to
    assert_equal ['donotreply@appfolio.com'], email.from
    assert_equal 'Image Shared from Image-Sharer!', email.subject
    assert_equal expected_email_body_html('Hello!', 'https://isexample.com/image.png'),
                 email.html_part.body.to_s
    assert_equal expected_email_body_text('Hello!', 'https://isexample.com/image.png'),
                 email.text_part.body.to_s
  end

  test 'share email with empty message' do
    email = ImageMailer.send_share_email(email_address: 'me@example.com',
                                         message: '',
                                         url: 'https://isexample.com/image.png')

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['me@example.com'], email.to
    assert_equal ['donotreply@appfolio.com'], email.from
    assert_equal 'Image Shared from Image-Sharer!', email.subject
    assert_equal expected_email_body_html('', 'https://isexample.com/image.png'),
                 email.html_part.body.to_s
    assert_equal expected_email_body_text('', 'https://isexample.com/image.png'),
                 email.text_part.body.to_s
  end

  private

  def expected_email_body_html(message, url)
    message_block = message.empty? ? '' : "    <p>Your friend said:</p>\n    <p>#{message}</p>\n"

    <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style>
          /* Email styles need to be inline */
        </style>
      </head>

      <body>
        <h1>Hello from Image Sharer!</h1>
    <p>
      You have been sent an image!
    </p>
    #{message_block}<img src="#{url}" alt="Image" />
    <p>Thanks for viewing and have a great day!</p>

    <p style="opacity: 0.5;"> Want to see more images? Check out our <a href="http://localhost:3000/">website</a>
    </p>

      </body>
    </html>
    HTML
  end

  def expected_email_body_text(message, url)
    message_block = message.empty? ? '' : "  Your friend said:\n  #{message}\n"

    <<~TEXT
    Hello from Image Sharer!
    =========================

    You have been sent an image, click #{url} to check it out.

    #{message_block}Thanks for viewing and have a great day!

    Want to see more images? Check out our website: http://localhost:3000/

    TEXT
  end
end
