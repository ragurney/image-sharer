# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

url_list = %w(https://static.pexels.com/photos/1518/black-and-white-city-bird-people.jpg
              http://digital-photography-school.com/wp-content/uploads/2007/02/black-and-white-tips.jpg
              https://s-media-cache-ak0.pinimg.com/736x/56/5a/9d/565a9d198452ee8884db9240b63b9ee4.jpg
              http://inspirationfeeed.files.wordpress.com/2014/03/20481.jpg
              https://www.art-competition.net/images/winners/Black_White/H7_Laurent_Baheux_Lion-portrait-Kenya.jpg)

4.times do
  url_list.each do |url|
    Image.create!(url: url)
  end
end
