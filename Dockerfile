# SPARCRequest
#
# This image builds from the base SPARCRequest image and includes organization specific overrides.
#
# To build:
#
# docker build --rm -t my_sparc_request --pull .
FROM my_sparc_request_base

COPY ./deps/sparc/config/* /sparc/config/

# The following are typical files that you may wish to add if you have customizations
# COPY ./deps/sparc/assets/images/my_logo.jpg /sparc/app/assets/images/logos/my_logo.jpg
# COPY ./deps/sparc/assets/images/blank_logo.jpg /sparc/app/assets/images/logos/blank_logo.jpg
# COPY ./deps/sparc/locales/*.yml /sparc/config/locales/
# COPY ./deps/sparc/tasks/*.rake /sparc/lib/tasks/
# COPY ./deps/sparc/reports/*.rb /sparc/app/lib/reports/
