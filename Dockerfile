FROM elixir
RUN mix local.hex --force && mix local.rebar --force
ADD mix.exs mix.lock config /tmp/
RUN cd /tmp &&  mkdir -p /opt/app/deps && mix deps.get && cp -r deps /opt/app

WORKDIR opt/app
ADD . .
ENV MIX_ENV=prod
ENV REMOTE_GIT_PORT=22
ENV PORT=4000
RUN mix compile

EXPOSE 4000
CMD ["ssh-agent", "sh", "./start.sh"]
