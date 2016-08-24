url_list = %w(https://static.pexels.com/photos/1518/black-and-white-city-bird-people.jpg
              http://digital-photography-school.com/wp-content/uploads/2007/02/black-and-white-tips.jpg
              https://s-media-cache-ak0.pinimg.com/736x/56/5a/9d/565a9d198452ee8884db9240b63b9ee4.jpg
              http://inspirationfeeed.files.wordpress.com/2014/03/20481.jpg
              https://www.art-competition.net/images/winners/Black_White/H7_Laurent_Baheux_Lion-portrait-Kenya.jpg)

4.times do
  Image.create!([
    { url: url_list[0] },
    { url: url_list[1] },
    { url: url_list[2] },
    { url: url_list[3] },
    { url: url_list[4] }
  ])
end
