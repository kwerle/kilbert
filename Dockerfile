FROM ruby:3.1.2

# Speed up install of gems
RUN bundle config jobs 6

WORKDIR /app/src

COPY Gemfile* ./

RUN bundle

COPY . .

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# RUN rake assets:precompile

EXPOSE 3000

CMD rails s -b 0.0.0.0
