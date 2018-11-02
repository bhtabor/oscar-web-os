[ ![Codeship Status for rotati/oscar-web-os](https://app.codeship.com/projects/f6b80f60-6b75-0135-9771-7e9523f697c6/status?branch=master)](https://app.codeship.com/projects/242146)

# OSCaR

Open Source Case-management and Record-keeping.

### Requirements

* Postgres(>= 9.4)
* Ruby(2.3.3)
* Rails(4.2.2)

### Getting Start

Given that you got all the requirements running on your local machine.


Clone the project to your local machine:

```
  git clone git@github.com:rotati/oscar-web-os.git
```

Navigate to the project directory and create `.env` in project root path, and copy all content in `.env.example` and replace all variable values to fit your local machine.

Then run:

```
  bundle install

  rake db:create

  rake db:migrate
  
  # Create your instance/organization, "ngo_subdomain" must be lowercase without underscore.
  Organization.create_and_build_tanent(short_name: 'ngo_subdomain', full_name: 'NGO Name', logo: File.open(Rails.root.join('path_to_your_ngo_logo')))

  rake db:seed  # to load basic data
```

Once the steps are done, start the server by running:

```
  rails server
```

Open a web browser and navigate to `http://lvh.me:3000`, and there you go!

### RSpec

Requirement

  Phanthomjs

  Pleas Install Phanthomjs as it is the dependency of poltegiest in order to run js true spec

  Install Phanthomjs for OSX

  ```
    npm install -g phantomjs
  ```

  Install Phanthomjs for Ubuntu

  ```
    sudo apt-get install phantomjs
  ```

The project is well tested using RSpec and Capybara.

To run all specs, testing environment must be setup.
Navigate to project root directory and run the following commands:

```
  bundle install RAILS_ENV=test

  rake db:create RAILS_ENV=test

  rake db:migrate RAILS_ENV=test

  rake db:seed RAILS_ENV=test  # to load some basic data
```

To run all specs, in your project root directory in terminal, run this command:

```
  rspec
```

### Issue Reporting

If you experience with bugs or need further improvement, please create a new issue in the repo issue list.

### Contributing to OSCaR

Pull requests are very welcome. Before submitting a pull request, please make sure that your changes are well tested. Pull requests without tests will not be accepted.

### Authors

OSCaR is developed in partnership by [Rotati Consulting](http://www.rotati.com) and [CIF](http://www.childreninfamilies.org)

### License

OSCaR Web Application is released under [AGPL](http://www.gnu.org/licenses/agpl-3.0-standalone.html)
