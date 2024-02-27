# CommandDash

CLI enhancments to Dash-AI. Coming Soon ✨

### Configuring Proto

```bash
dart pub global activate protoc_plugin
```

```bash
protoc -I protos/ protos/task_processor.proto --dart_out=grpc:lib/generated
```