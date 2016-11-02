image_list = [
  %w(https://static.pexels.com/photos/1518/black-and-white-city-bird-people.jpg
     cool),
  %w(http://digital-photography-school.com/wp-content/uploads/2007/02/black-and-white-tips.jpg
     wow),
  %w(https://s-media-cache-ak0.pinimg.com/736x/56/5a/9d/565a9d198452ee8884db9240b63b9ee4.jpg
     neat
     cool),
  %w(http://inspirationfeeed.files.wordpress.com/2014/03/20481.jpg
     wow
     neat
     spiffy),
  %w(https://www.art-competition.net/images/winners/Black_White/H7_Laurent_Baheux_Lion-portrait-Kenya.jpg
     neat),
  %w(https://upload.wikimedia.org/wikipedia/commons/c/c8/Altja_j%C3%B5gi_Lahemaal.jpg
     cool
     awesome),
  %w(http://www.betterphoto.com/uploads/processed/0724/0706140402101moore_5-2.jpg
     neat
     much-wow
     such-awesome),
  %w(http://designgrapher.com/wp-content/uploads/2013/06/nature-photographs.jpg
     cool
     wow),
  %w(http://webneel.com/daily/sites/default/files/images/daily/10-2013/25-nature-photography-lake-by-suhartoyo.preview.jpg
     wow,
     cool),
  %w(https://archive.org/download/nature-pic/nature-pic.jpg
     amazing
     cool),
  %w(https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Ed_White_performs_first_U.S._spacewalk_crop.jpg/1280px-Ed_White_performs_first_U.S._spacewalk_crop.jpg
     neat
     space),
  %w(http://img.wallpaperfolder.com/f/661D5E2801F7/abstract-nature-photography.jpg
     incredible
     nature
     cool),
  %w(http://www.markhamblin.com/graphics/siteimages/home-slideshow-4.jpg
     much
     wow
     such
     awesome),
  %w(http://www.johnshawphoto.com/wp-content/uploads/galleries/post-8/full/090429_JSP_3263.jpg
     wow
     cool),
  %w(http://www.araspot.com/wp-content/uploads/2015/08/beauty-nature-reflections-wallpaper-high-quality-bk1vfmp010.jpg
     neat),
  %w(https://static.pexels.com/photos/7919/pexels-photo.jpg
     woah
     coolio),
  %w(http://g02.a.alicdn.com/kf/HTB19DPYHVXXXXbMXpXXq6xXFXXXX/Vinyl-Photography-Backdrops-font-b-Nature-b-font-font-b-scene-b-font-theme-Prop-font.jpg
     wow
     neat),
  %w(http://wall.sf.co.ua/13/01/wallpaper-2601007.jpg
     awesome),
  %w(https://www.smashingmagazine.com/wp-content/uploads/images/space-photography/space-photography-119.jpg
     cool
     picture),
  %w(http://3.bp.blogspot.com/-I8-Huhs9pK4/VPf11IvsLTI/AAAAAAAABUM/bILtg5d8fEU/s1600/space-universe-wallpapers-background-images-photography-195979.jpg
     neat)
]
user = User.find_by(email: 'admin@email.com')

Image.create!(
  image_list.map do |image|
    {
      url: image[0],
      tag_list: image.drop(1),
      user_id: user ? user.id : 1
    }
  end
)
