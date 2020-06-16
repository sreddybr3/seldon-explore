FROM tensorflow/serving:1.15.0

WORKDIR /
RUN mkdir /models/half-plus-two
RUN mkdir /models/half-plus-three
ADD models/half-plus-two/ /models/half-plus-two/
ADD models/half-plus-three/ /models/half-plus-three/
ADD models/models.config /models/models.config

ENV model_config_file=/models/models.config

# Create a script that runs the model server so we can use environment variables
# while also passing in arguments from the docker command line
RUN echo '#!/bin/bash \n\n\
tensorflow_model_server --port=8500 --rest_api_port=8501 \
--model_config_file=/models/models.config \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]