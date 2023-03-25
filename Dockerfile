FROM elixir:1.13 as build

WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

COPY mix.exs /app/
COPY mix.lock /app/

ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY lib /app/lib
RUN mix release


FROM elixir:1.13

EXPOSE 7890
ENV MIX_ENV=prod

WORKDIR /app
COPY --from=build app/_build/prod/rel/investor .
COPY --from=build app/lib .

CMD ./bin/investor start
