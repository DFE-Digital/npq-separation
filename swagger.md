# Swagger

## Spike

A [spike](https://github.com/DFE-Digital/npq-registration/pull/1118) was created on the NPQ registration app to generate a Swagger yaml spec and documentation UI using the `rswag` gem.

We looked at other gems that can do this, but `rswag` appears to be the defacto-standard and most flexible all-round way of Swaggerizing a Rails application and generating a documentation UI.

`rswag` generates a Swagger yaml file from descriptive specs, which is nice as it kills two birds with one stone. It should do everything that we would need and more.

The `rswag-ui` package leverages `swagger-ui` under the hood, which generates a UI that mostly matches Mark's design and has a decent plugin system for customizing the various components. It uses React and appears to operate as Rack middleware, which is a bit of a pain when it comes to customising the `Components`. The issue is we can't import React with `webpacker` as the helpers aren't available in middleware. Instead, we pulled React from a CDN and inlined the plugins to customise the UI. There's probably a better way of doing this.

Between the plugin system and CSS/custom JS we should be able to change any of the design we like, though some changes are easier than others. I wasn't able to hide the `Topbar` component, for example, as it appears to set Redux state for other parts of the page, so I had to hide this with CSS. If we want to modify a particular `Component` we have to redefine it and pass it in as a plugin, which is OK for most scenarios but some of the default components are quite complex and redefining them can be verbose.

Most of the Redux state is pulled from the `swagger.yaml` generated in Rails, but `swagger-ui` also has a way of overriding selectors and reducers so that we can modify the state if we have to.

Overall I think its a decent solution, as long as we don't go too crazy with the UI it should be fairly painless to implement.

If we do go with `rswag` we should add the rails `rswag` task to CI to ensure the yaml file doesn't get modified manually (which is what has happened on ECF!).

On looking at what other Ruby projects in DfE use for Swagger, there's not very many but they all appear to use `rswag`:

- https://github.com/DFE-Digital/curriculum-materials
- https://github.com/DFE-Digital/publish-teacher-training
- https://github.com/DFE-Digital/early-careers-framework

We also checked the `alphagov`` repositories and couldn't find any Ruby projects using swagger.

There is also a [DfE fork](https://github.com/DFE-Digital/open-api-rswag) of `rswag` that adds support for v3 of the openapi spec, but as of v2.3.0 the core `rswag` gem supports v3 so we shouldn't need to use this. That being said, if we put work into making `swagger-ui` look different from the default and more geared towards a GOV.UK audience it may be worth having our own fork that we can share.

|  Design |  Implementation |
|---|---|
| <img width="780" alt="Screenshot 2024-01-24 at 13 59 23" src="https://github.com/DFE-Digital/npq-registration/assets/29867726/382bfccf-3039-49f8-8178-56ca58c0ac07"> |  <img width="780" alt="Screenshot 2024-01-24 at 13 56 55" src="https://github.com/DFE-Digital/npq-registration/assets/29867726/ef5c78ca-fb84-4298-bd2b-a5a6b9f31f4a"> |

## Accessibility

It's been flagged that the `swagger-ui` is not all that accessible [see this issues](https://github.com/swagger-api/swagger-ui/issues/7350). The Apply for teacher training service have created [their own technical API documentation](https://www.apply-for-teacher-training.service.gov.uk/api-docs/v1.4/reference) that uses the same OpenAPI spec that we could look at leveraging if we feel this is an issue.
