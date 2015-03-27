Best Practices

- use the same kernel in all environments
- use the same base image (at least for every OS version)
-- same layer will be used for all images
- layer technologies on base image
-- example: one image with java, one with python, one with node...
- each container should contain a single process
-- each process can be deployed, scaled and reused independently
- state management?
-- volumes
- processes within containers should respond to signals for clean shutdown
- logging - store logs on a volume
- monitoring - cadvisor?