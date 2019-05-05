FROM ruby:2.6.3

ENV EDITOR vi

# Speed up install of gems
RUN bundle config jobs 6

WORKDIR /app/src

COPY Gemfile* ./

RUN bundle install -j 6

COPY . .

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

RUN rake assets:precompile

EXPOSE 3000

CMD bash -c 'rake db:migrate && rails s -b 0.0.0.0'
