#
# Podfile
# mas-cli
#

platform :osx, '10.13'

target 'mas' do
  use_frameworks!

  pod 'Commandant', git: "https://github.com/phatblat/Commandant.git", branch: "cocoapods"
  pod 'Result'

  target 'mas-tests' do
    inherit! :search_paths

    pod 'Quick'
    pod 'Nimble'

  end

end
