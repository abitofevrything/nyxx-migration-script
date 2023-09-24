import 'dart:io';

import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

int copiedFiles = 0, rewrittenFiles = 0;

void main(List<String> arguments) async {
  arguments = arguments.map((e) => File(e).absolute.uri.normalizePath().toFilePath()).toList();

  final roots = ContextLocator().locateRoots(includedPaths: arguments);
  final context = ContextBuilder().createContext(contextRoot: roots.single);

  final input = Directory(roots.single.root.path);
  final output = Directory.fromUri(input.absolute.uri.resolve('../migrated'));

  if (output.existsSync()) {
    print('${output.path} already exists! Please delete it and try again.');
    return;
  }
  output.createSync();

  print('Output will be written to: ${output.path}');

  await Future.wait(
    arguments
        .expand((path) => File(path).existsSync()
            ? [File(path)]
            : Directory(path).listSync(recursive: true).whereType<File>())
        .map((file) => handle(
              file,
              context.currentSession,
              input,
              output,
            )),
  );

  print('Rewrote $rewrittenFiles files and copied $copiedFiles files to ${output.path}');
}

Future<void> handle(File file, AnalysisSession session, Directory input, Directory output) async {
  final outputPath = file.absolute.path.replaceFirst(input.absolute.path, output.absolute.path);
  final outputFile = File(outputPath);

  final outputDirectory = outputFile.parent;
  await outputDirectory.create(recursive: true);

  if (outputFile.path.endsWith('.dart')) {
    print('Rewriting: ${file.path}');

    final unit = await session.getResolvedUnit(file.path) as ResolvedUnitResult;

    final rewritten = unit.unit.accept(NyxxRewriter())!;

    await outputFile.writeAsString(rewritten.toString());

    rewrittenFiles++;
  } else if (outputFile.path.endsWith('/pubspec.yaml')) {
    print('Updating dependencies: ${file.path}');

    final content = await file.readAsString();

    await outputFile.writeAsString(
      content
          .replaceAll(RegExp(r'nyxx:.+'), 'nyxx: ^6.0.0-dev.3')
          .replaceAll(RegExp(r'nyxx_commands:.+'), 'nyxx_commands: ^6.0.0-dev.1')
          .replaceAll(RegExp(r'nyxx_extensions:.+'), 'nyxx_extensions: ^4.0.0-dev.1')
          .replaceAll(RegExp(r'http: \^0\..+'), 'http: ^1.0.0')
          .replaceAll('nyxx_interactions:', '# nyxx_interactions:'),
    );

    rewrittenFiles++;
  } else if (!outputFile.path.endsWith('/pubspec.lock')) {
    await file.openRead().pipe(outputFile.openWrite());
    copiedFiles++;
  }
}

const mapping = {
  // Types
  'ActionMetadataBuilder': 'REMOVED_ActionMetadataBuilder',
  'ActionStructureBuilder': 'REMOVED_ActionStructureBuilder',
  'ActionTypes': 'ActionType',
  'ActivityType': 'REMOVED_ActivityType',
  'ArgChoiceBuilder': 'CommandOptionChoiceBuilder',
  'AttachmentMetadataBuilder': 'REMOVED_AttachmentMetadataBuilder',
  'AuditLogEntryType': 'AuditLogEvent',
  'AvailableTagBuilder': 'ForumTagBuilder',
  'CacheOptions': 'RestClientOptions',
  'CachePolicy': 'REMOVED_CachePolicy',
  'CachePolicyLocation': 'REMOVED_CachePolicyLocation',
  'Cacheable': 'REMOVED_Cacheable_Use_Partials',
  'CdnConstants': 'REMOVED_CdnConstants',
  'CdnHttpRouteParam': 'HttpRouteParam',
  'CdnHttpRoutePart': 'HttpRoutePart',
  'ChangeKeyType': 'String',
  'ChannelCachePolicy': 'REMOVED_ChannelCachePolicy',
  'ChannelMultiSelectBuilder': 'SelectMenuBuilder',
  'ClientOptions': 'GatewayApiOptions',
  'ComponentMessageBuilder': 'MessageBuilder',
  'ComponentRowBuilder': 'ActionRowBuilder',
  'ComponentType': 'MessageComponentType',
  'Constants': 'RestApiOptions',
  'Convertable': 'REMOVED_Convertable',
  'DisconnectEventReason': 'REMOVED_DisconnectEventReason',
  'Disposable': 'REMOVED_Disposable',
  'EmbedBuilderArgumentException': 'REMOVED_EmbedBuilderArgumentException',
  'Encoding': 'GatewayPayloadFormat',
  'EntityMetadataBuilder': '',
  'EventTypes': 'AutoModerationEventType',
  'ForumSortOrder': 'ForumSort',
  'GuildEventBuilder': 'ScheduledEventBuilder',
  'GuildEventPrivacyLevel': 'PrivacyLevel',
  'GuildEventStatus': 'EventStatus',
  'GuildEventType': 'ScheduledEntityType',
  'GuildFeature': 'GuildFeatures',
  'GuildNsfwLevel': 'NsfwLevel',
  'IActionMetadata': 'ActionMetadata',
  'IActionStructure': 'AutoModerationAction',
  'IActivity': 'Activity',
  'IActivityEmoji': 'Emoji',
  'IActivityFlags': 'ActivityFlags',
  'IActivityParty': 'ActivityParty',
  'IActivityTimestamps': 'ActivityTimestamps',
  'IAppTeam': 'Team',
  'IAppTeamMember': 'TeamMember',
  'IAppTeamUser': 'PartialUser',
  'IArgChoice': 'CommandOptionChoice',
  'IAttachment': 'Attachment',
  'IAuditLog': 'AuditLogManager',
  'IAuditLogChange': 'AuditLogChange',
  'IAuditLogEntry': 'AuditLogEntry',
  'IAuditLogOptions': 'AuditLogEntryInfo',
  'IAutoModerationActionExecutionEvent': 'AutoModerationActionExecutionEvent',
  'IAutoModerationRule': 'AutoModerationRule',
  'IAutoModerationRuleCreateEvent': 'AutoModerationRuleCreateEvent',
  'IAutoModerationRuleDeleteEvent': 'AutoModerationRuleDeleteEvent',
  'IAutoModerationRuleUpdateEvent': 'AutoModerationRuleUpdateEvent',
  'IAutocompleteInteractionEvent': 'ApplicationCommandAutocompleteInteraction',
  'IBan': 'Ban',
  'IBaseGuildEmoji': 'Emoji',
  'IButtonInteraction': 'MessageComponentInteraction',
  'IButtonInteractionEvent': 'MessageComponentInteraction',
  'ICache': 'Cache',
  'ICacheableTextChannel': 'TextChannel',
  'ICategoryGuildChannel': 'GuildCategory',
  'ICdnHttpEndpoints': 'REMOVED_ICdnHttpEndpoints',
  'ICdnHttpRoute': 'HttpRoute',
  'IChannel': 'Channel',
  'IChannelCreateEvent': 'ChannelCreateEvent',
  'IChannelDeleteEvent': 'ChannelDeleteEvent',
  'IChannelMultiSelectInteraction': 'MessageComponentInteraction',
  'IChannelMultiSelectInteractionEvent': 'MessageComponentInteraction',
  'IChannelPinsUpdateEvent': 'ChannelPinsUpdateEvent',
  'IChannelUpdateEvent': 'ChannelUpdateEvent',
  'IChatContext': 'ChatContext',
  'IClientOAuth2Application': 'Application',
  'IClientStatus': 'ClientStatus',
  'IClientUser': 'User',
  'ICommandOption': 'CommandOption',
  'ICommandsSync': 'REMOVED_ICommandsSync',
  'IComponentInteraction': 'MessageComponentInteraction',
  'IComponentInteractionEvent': 'MessageComponentInteraction',
  'IContextData': 'ContextData',
  'IDMChannel': 'DmChannel',
  'IDisconnectEvent': 'Disconnecting',
  'IEmbed': 'Embed',
  'IEmbedAuthor': 'EmbedAuthor',
  'IEmbedField': 'EmbedField',
  'IEmbedFooter': 'EmbedFooter',
  'IEmbedProvider': 'EmbedProvider',
  'IEmbedThumbnail': 'EmbedThumbnail',
  'IEmbedVideo': 'EmbedVideo',
  'IEmoji': 'Emoji',
  'IEntityMetadata': 'EntityMetadata',
  'IEnum': 'REMOVED_IEnum',
  'IEventController': 'REMOVED_IEventController',
  'IFieldError': 'FieldError',
  'IForumChannel': 'ForumChannel',
  'IForumChannelTags': 'ChannelFlags',
  'IForumTag': 'ForumTag',
  'IGameAssets': 'ActivityAssets',
  'IGameSecrets': 'ActivitySecrets',
  'IGuild': 'Guild',
  'IGuildBanAddEvent': 'GuildBanAddEvent',
  'IGuildBanRemoveEvent': 'GuildBanRemoveEvent',
  'IGuildChannel': 'GuildChannel',
  'IGuildCreateEvent': 'GuildCreateEvent',
  'IGuildDeleteEvent': 'GuildDeleteEvent',
  'IGuildEmoji': 'GuildEmoji',
  'IGuildEmojiPartial': 'Emoji',
  'IGuildEmojisUpdateEvent': 'GuildEmojisUpdateEvent',
  'IGuildEvent': 'ScheduledEvent',
  'IGuildEventCreateEvent': 'GuildScheduledEventCreateEvent',
  'IGuildEventDeleteEvent': 'GuildScheduledEventDeleteEvent',
  'IGuildEventUpdateEvent': 'GuildScheduledEventUpdateEvent',
  'IGuildEventUser': 'ScheduledEventUser',
  'IGuildMemberAddEvent': 'GuildMemberAddEvent',
  'IGuildMemberRemoveEvent': 'GuildMemberRemoveEvent',
  'IGuildMemberUpdateEvent': 'GuildMemberUpdateEvent',
  'IGuildPreview': 'GuildPreview',
  'IGuildSticker': 'GuildSticker',
  'IGuildStickerUpdate': 'GuildStickersUpdateEvent',
  'IGuildUpdateEvent': 'GuildUpdateEvent',
  'IGuildWelcomeChannel': 'WelcomeScreenChannel',
  'IGuildWelcomeScreen': 'WelcomeScreen',
  'IHttpEndpoints': 'REMOVED_IHttpEndpoints',
  'IHttpErrorData': 'HttpErrorData',
  'IHttpErrorEvent': 'REMOVED_IHttpErrorEvent',
  'IHttpResponse': 'HttpResponse',
  'IHttpResponseError': 'HttpResponseError',
  'IHttpResponseEvent': 'REMOVED_IHttpResponseEvent',
  'IHttpResponseSuccess': 'HttpResponseSuccess',
  'IHttpRoute': 'HttpRoute',
  'IHttpRoutePart': 'HttpRoutePart',
  'IInteraction': 'Interaction',
  'IInteractionDataResolved': 'ResolvedData',
  'IInteractionEvent': 'Interaction',
  'IInteractionEventWithAcknowledge': 'MessageResponse',
  'IInteractionInteractiveContext': 'InteractionInteractiveContext',
  'IInteractionOption': 'InteractionOption',
  'IInteractionSlashDataResolved': 'ResolvedData',
  'IInteractions': 'NyxxGateway',
  'IInteractionsEndpoints': 'REMOVED_IInteractionsEndpoints',
  'IInteractiveContext': 'InteractiveContext',
  'IInvite': 'Invite',
  'IInviteCreatedEvent': 'InviteCreateEvent',
  'IInviteDeletedEvent': 'InviteDeleteEvent',
  'IInviteWithMeta': 'InviteWithMetadata',
  'ILinkMessageButton': 'ButtonComponent',
  'IMember': 'Member',
  'IMemberChunkEvent': 'GuildMembersChunkEvent',
  'IMemberFlags': 'MemberFlags',
  'IMentionableMultiSelectInteraction': 'MessageComponentInteraction',
  'IMentionableMultiSelectInteractionEvent': 'MessageComponentInteraction',
  'IMessage': 'Message',
  'IMessageAuthor': 'MessageAuthor',
  'IMessageButton': 'ButtonComponent',
  'IMessageChannelMultiSelect': 'SelectMenuComponent',
  'IMessageComponent': 'MessageComponent',
  'IMessageComponentEmoji': 'Emoji',
  'IMessageDeleteBulkEvent': 'MessageBulkDeleteEvent',
  'IMessageDeleteEvent': 'MessageDeleteEvent',
  'IMessageMentionableMultiSelect': 'SelectMenuComponent',
  'IMessageMultiselect': 'SelectMenuComponent',
  'IMessageMultiselectOption': 'SelectMenuOption',
  'IMessageReactionAddedEvent': 'MessageReactionAddEvent',
  'IMessageReactionEvent': 'REMOVED_IMessageReactionEvent',
  'IMessageReactionRemoveEmojiEvent': 'MessageReactionRemoveEmojiEvent',
  'IMessageReactionRemovedEvent': 'MessageReactionRemoveEvent',
  'IMessageReactionsRemovedEvent': 'MessageReactionRemoveAllEvent',
  'IMessageReceivedEvent': 'MessageCreateEvent',
  'IMessageReference': 'MessageReference',
  'IMessageRoleMultiSelect': 'SelectMenuComponent',
  'IMessageTextInput': 'TextInputComponent',
  'IMessageTimestamp': 'REMOVED_IMessageTimestamp',
  'IMessageUpdateEvent': 'MessageUpdateEvent',
  'IMessageUserMultiSelect': 'SelectMenuComponent',
  'IMinimalGuildChannel': 'GuildChannel',
  'IModalInteraction': 'ModalSubmitInteraction',
  'IModalInteractionEvent': 'ModalSubmitInteraction',
  'IModalResponseMixin': 'ModalResponse',
  'IMultiselectInteraction': 'MessageComponentInteraction',
  'IMultiselectInteractionEvent': 'MessageComponentInteraction',
  'INyxx': 'Nyxx',
  'INyxxRest': 'NyxxRest',
  'INyxxWebsocket': 'NyxxGateway',
  'IOAuth2Application': 'Application',
  'IPartialChannel': 'PartialChannel',
  'IPartialPresence': 'PresenceUpdateEvent',
  'IPartialSticker': 'Sticker',
  'IPermissions': 'Permissions',
  'IPermissionsOverrides': 'PermissionOverwrite',
  'IPluginManager': 'REMOVED_IPluginManager',
  'IPresenceUpdateEvent': 'PresenceUpdateEvent',
  'IRatelimitEvent': 'REMOVED_IRatelimitEvent',
  'IRawEvent': 'RawDispatchEvent',
  'IReaction': 'Reaction',
  'IReadyEvent': 'ReadyEvent',
  'IReferencedMessage': 'MessageReference', // ?
  'IResolvableGuildEmojiPartial': 'Emoji',
  'IResolvedSelectInteraction': 'MessageComponentInteraction',
  'IRestEventController': 'REMOVED_IRestEventController',
  'IRole': 'Role',
  'IRoleCreateEvent': 'GuildRoleCreateEvent',
  'IRoleDeleteEvent': 'GuildRoleDeleteEvent',
  'IRoleMultiSelectInteractionEvent': 'MessageComponentInteraction',
  'IRoleTags': 'RoleTags',
  'IRoleUpdateEvent': 'GuildRoleUpdateEvent',
  'ISend': 'REMOVED_ISend',
  'IShard': 'Shard',
  'IShardManager': 'Gateway',
  'ISlashCommand': 'ApplicationCommand',
  'ISlashCommandInteraction': 'ApplicationCommandInteraction',
  'ISlashCommandInteractionEvent': 'ApplicationCommandInteraction',
  'ISlashCommandPermissionOverride': 'CommandPermission',
  'ISlashCommandPermissionOverrides': 'CommandPermissions',
  'IStageChannelInstance': 'StageInstance',
  'IStageInstanceEvent': 'StageInstanceCreateEvent',
  'IStageVoiceGuildChannel': 'GuildStageChannel',
  'IStandardSticker': 'GlobalSticker',
  'ISticker': 'Sticker',
  'IStickerPack': 'StickerPack',
  'ITextChannel': 'TextChannel',
  'ITextGuildChannel': 'GuildTextChannel',
  'ITextVoiceTextChannel': 'GuildVoiceChannel',
  'IThreadChannel': 'Thread',
  'IThreadCreateEvent': 'ThreadCreateEvent',
  'IThreadDeletedEvent': 'ThreadDeleteEvent',
  'IThreadListResultWrapper': 'ThreadList',
  'IThreadListSyncEvent': 'ThreadListSyncEvent',
  'IThreadMember': 'ThreadMember',
  'IThreadMemberUpdateEvent': 'ThreadMemberUpdateEvent',
  'IThreadMemberWithMember': 'ThreadMember',
  'IThreadMembersUpdateEvent': 'ThreadMembersUpdateEvent',
  'IThreadPreviewChannel': 'Thread',
  'IThreadUpdateEvent': 'ThreadUpdateEvent',
  'ITriggerMetadata': 'TriggerMetadata',
  'ITypingEvent': 'TypingStartEvent',
  'IUnicodeEmoji': 'TextEmoji',
  'IUser': 'User',
  'IUserFlags': 'UserFlags',
  'IUserMultiSelectInteraction': 'MessageComponentInteraction',
  'IUserMultiSelectInteractionEvent': 'MessageComponentInteraction',
  'IUserUpdateEvent': 'UserUpdateEvent',
  'IVoiceGuildChannel': 'GuildVoiceChannel',
  'IVoiceRegion': 'VoiceRegion',
  'IVoiceServerUpdateEvent': 'VoiceServerUpdateEvent',
  'IVoiceState': 'VoiceState',
  'IVoiceStateUpdateEvent': 'VoiceStateUpdateEvent',
  'IWebhook': 'Webhook',
  'IWebhookUpdateEvent': 'WebhooksUpdateEvent',
  'IWebsocketEventController': 'REMOVED_IWebsocketEventController',
  'InMemoryCache': 'Cache',
  'InteractionBackend': 'REMOVED_InteractionBackend',
  'InteractionEventAbstract': 'Interaction',
  'InteractionEventWithAcknowledge': 'Interaction',
  'InvalidShardException': 'REMOVED_InvalidShardException',
  'InvalidSnowflakeException': 'FormatException',
  'KeywordPresets': 'KeywordPresetType',
  'LinkButtonBuilder': 'ButtonBuilder',
  'LockFileCommandSync': 'REMOVED_LockFileCommandSync',
  'ManualCommandSync': 'REMOVED_ManualCommandSync',
  'MemberBuilder': 'MemberBuilder',
  'MemberCachePolicy': 'REMOVED_MemberCachePolicy',
  'MemberFlagsBuilder': 'Flags<MemberFlags>',
  'Mentionable': 'REMOVED_Mentionable',
  'MentionableMultiSelectBuilder': 'SelectMenuBuilder',
  'MessageCachePolicy': 'REMOVED_MessageCachePolicy',
  'MessageComponentEmoji': 'Emoji',
  'MessageDecoration': 'REMOVED_MessageDecoration',
  'MessageFlagBuilder': 'Flags<MessageFlags>',
  'MissingTokenError': 'REMOVED_MissingTokenError',
  'MultiselectBuilder': 'SelectMenuBuilder',
  'MultiselectOptionBuilder': 'SelectMenuOptionBuilder',
  'NyxxFactory': 'Nyxx',
  'OPCodes': 'Opcode',
  'PermissionOverrideBuilder': 'PermissionOverwriteBuilder',
  'PermissionsBuilder': 'Flags<Permissions>',
  'PermissionsConstants': 'Permissions',
  'PermissionsUtils': 'REMOVED_PermissionsUtils',
  'ReplyBuilder': 'REMOVED_ReplyBuilder',
  'RoleMultiSelectBuilder': 'SelectMenuBuilder',
  'SlashCommandBuilder': 'ApplicationCommandBuilder',
  'SlashCommandPermissionType': 'CommandPermissionType',
  'SlashCommandType': 'ApplicationCommandType',
  'SnowflakeCache': 'Cache',
  'StageChannelInstancePrivacyLevel': 'PrivacyLevel',
  'TextChannelBuilder': 'GuildTextChannelBuilder',
  'ThreadArchiveTime': 'REMOVED_ThreadArchiveTime',
  'TimeStampStyle': 'REMOVED_TimeStampStyle',
  'TriggerMetadataBuilder': 'TriggerMetadata',
  'TriggerTypes': 'TriggerType',
  'UnicodeEmoji': 'TextEmoji',
  'UnrecoverableNyxxError': 'REMOVED_UnrecoverableNyxxError',
  'UserMultiSelectBuilder': 'SelectMenuBuilder',
  'VoiceActivityType': 'TODO_VoiceActivityType',
  'VoiceChannelBuilder': 'GuildVoiceChannelBuilder',
  'WebsocketInteractionBackend': 'REMOVED_WebsocketInteractionBackend',

  // Methods, functions and constructors
  'ArgChoiceBuilder.new()': 'CommandOptionChoiceBuilder(name: {1}, value: {2})',
  'ButtonBuilder.new()':
      'ButtonBuilder(style: {3}, label: {1}, emoji: {emoji}, customId: {2}, isDisabled: {disabled})',
  'Cacheable.download()': '{0}.fetch()',
  'Cacheable.getFromCache()': '{0}.manager.cache[{0}.id]',
  'Cacheable.getOrDownload()': '{0}.get()',
  'CacheableTextChannel.download()': '(await {0}.fetch() as TextChannel)',
  'CacheableTextChannel.fetchMessage()': '{0}.messages.fetch({1})',
  'CacheableTextChannel.getFromCache()': '({0}.manager.cache[{0}.id] as TextChannel?)',
  'CacheableTextChannel.getOrDownload()': '(await {0}.get() as TextChannel)',
  'CommandOptionBuilder.new()':
      'CommandOptionBuilder(type: {1}, name: {2}, nameLocalizations: {localizationsName}, description: {3}, descriptionLocalizations: {localizationsDescription}, options: {options}, isRequired: {required}, choices: {choices}, channelTypes: {channelTypes}, maxValue: {max}, minValue: {min}, hasAutocomplete: {autoComplete})',
  'ComponentMessageBuilder.addComponentRow()':
      '{0}.components!./* TODO: This could be null! */add({1})',
  'ComponentRowBuilder.addComponent()': '{0}.components.add({1})',
  'Disposable.dispose()': '{0}.close()',
  'IButtonInteractionEvent.sendFollowup()': '{0}.createFollowup({1}, isEphemeral: {hidden})',
  'IGuild.fetchMember()': '{0}.members.fetch({1})',
  'IGuild.fetchRoles()': '{0}.roles.list()',
  'IGuild.searchMembersGateway()':
      '({0}.manager.client as NyxxGateway).gateway.listGuildMembers({0}.id, query: {1}, limit: {limit})',
  'IHttpEndpoints.addRoleToUser()': '{0}.guilds[{1}].members[{3}].addRole({2})',
  'IHttpEndpoints.createGuildEvent()': '{0}.guilds[{1}].scheduledEvents.create({2})',
  'IHttpEndpoints.downloadMessages()':
      '({0}.channels[{1}] as PartialTextChannel).messages.fetchMany(around: {around}, after: {after}, before: {before}, limit: {limit})',
  'IHttpEndpoints.editGuildEvent()': '{0}.guilds[{1}].scheduledEvents[{2}].update({3})',
  'IHttpEndpoints.editGuildMember()':
      '{0}.guilds[{1}].members.update({2}, {builder}, auditLogReason: {auditReason})',
  'IHttpEndpoints.editMessage()':
      '({0}.channels[{1}] as PartialTextChannel).messages.update({2}, {3})',
  'IHttpEndpoints.fetchGuild()': '{0}.guilds.fetch({1}, withCounts: {withCounts})',
  'IHttpEndpoints.fetchGuildMember()': '{0}.guilds[{1}].members.fetch({2})',
  'IHttpEndpoints.fetchUser()': '{0}.users.fetch({1})',
  'IHttpEndpoints.removeRoleFromUser()': '{0}.guilds[{1}].members[{3}].removeRole({2})',
  'IHttpEndpoints.sendMessage()': '({0}.channels[{1}] as PartialTextChannel).sendMessage({2})',
  'IInteractionEventWithAcknowledge.acknowledge()': '{0}.interaction.acknowledge()',
  'IInteractionEventWithAcknowledge.getOriginalResponse()': '{0}.fetchOriginalResponse()',
  'IInteractionEventWithAcknowledge.sendFollowup()':
      '{0}.createFollowup({1}, isEphemeral: {hidden})',
  'IInteractions.create()': '{1}',
  'IInteractions.getGlobalOverridesInGuild()':
      '(await {0}.guilds[{1}].commands.listPermissions()).singleWhere((overrides) => overrides.command == null)',
  'IMember.avatarURL()': '{0}.avatar?.url.toString()',
  'IMember.edit()': '{0}.update({builder})',
  'IMultiselectInteractionEvent.sendFollowup()': '{0}.createFollowup({1}, isEphemeral: {hidden})',
  'INyxxWebsocket.fetchGuild()': '{0}.guilds.fetch({1}, withCounts: {withCounts})',
  'ISlashCommand.getPermissionOverridesInGuild()': '{0}.fetchPermissions({1})',
  'ITextChannel.downloadMessages()':
      '{0}.messages.fetchMany(around: {around}, after: {after}, before: {before}, limit: {limit})',
  'ITextChannel.fetchMessage()': '{0}.messages.fetch({1})',
  'IUser.avatarURL()': '{0}.avatar.url.toString()',
  'LinkButtonBuilder.new()':
      'ButtonBuilder(style: ButtonStyle.link, label: {1}, url: Uri.parse({2}), isDisabled: {disabled}, emoji: {emoji})',
  'MemberBuilder.new()': 'MemberUpdateBuilder()',
  'MessageBuilder.content()': 'MessageBuilder(content: {1})',
  'MessageBuilder.embed()': 'MessageBuilder(embeds: [{1}])',
  'MessageBuilder.empty()': 'MessageBuilder(content "‎")',
  'ModalBuilder.new()': 'ModalBuilder(customId: {1}, title: {2}, components: null /* TODO */ )',
  'MultiselectBuilder.new()':
      'SelectMenuBuilder(type: MessageComponentType.stringSelect, customId: {1}, options: {2})',
  'MultiselectOptionBuilder.new()':
      'SelectMenuOptionBuilder(label: {1}, value: {2}, description: {description}, emoji: {emoji}, isDefault: {isDefault})',
  'NyxxFactory.createNyxxWebsocket()': 'await Nyxx.connectGateway({1}, {2})',
  'SlashCommandBuilder.new()':
      'ApplicationCommandBuilder(name: {1}, type: {type} ?? ApplicationCommandType.chatInput, nameLocalizations: {localizationsName}, description: {2}, descriptionLocalizations: {localizationsDescription}, options: {3}, defaultMemberPermissions: {requiredPermissions}, hasDmPermission: {canBeUsedInDm}, isNsfw: {isNsfw})',
  'Snowflake.new()': 'Snowflake.parse({1})',
  'Snowflake.value()': 'Snowflake({1})',
  'Snowflake.zero()': 'Snowflake.zero',
  'TextInputBuilder.new()': 'TextInputBuilder(customId: {1}, style: {2}, label: {3})',
  'WebsocketInteractionBackend.new()': '{1}',

  // Fields
  'Attachment.filename': '.fileName',
  'ChannelType.category': 'ChannelType.guildCategory',
  'ChannelType.guildStage': 'ChannelType.guildStageVoice',
  'ChannelType.text': 'ChannelType.guildText',
  'ChannelType.voice': 'ChannelType.guildVoice',
  'ComponentMessageBuilder.componentRows': '.components',
  'ComponentType.button': 'MessageComponentType.button',
  'Constants.version': 'ApiOptions.nyxxVersion',
  'GatewayIntents.guildVoiceState': 'GatewayIntents.guildVoiceStates',
  'GuildEventBuilder.endDate': '.scheduledEndTime',
  'GuildEventBuilder.startDate': '.scheduledStartTime',
  'IAutocompleteInteractionEvent.focusedOption':
      '.data.options!.singleWhere((element) => element.isFocused == true)',
  'IAutocompleteInteractionEvent.interaction': '',
  'IAutocompleteInteractionEvent.options': '.data.options!',
  'IButtonInteraction.customId': '.data.customId',
  'IButtonInteraction.memberAuthor': '.member',
  'IButtonInteraction.userAuthor': '.user',
  'IButtonInteractionEvent.interaction': '',
  'IChannelMultiSelectInteractionEvent.interaction': '',
  'IComponentInteraction.customId': '.data.customId',
  'IComponentInteractionEvent.interaction': '',
  'IEventController.onButtonEvent':
      '.onMessageComponentInteraction.where((event) => event.interaction.data.type == MessageComponentType.button).map((e) => e.interaction)',
  'IEventController.onModalEvent': '.onModalSubmitInteraction.map((e) => e.interaction)',
  'IEventController.onMultiselectEvent':
      '.onMessageComponentInteraction.where((event) => event.interaction.data.type == MessageComponentType.stringSelect).map((e) => e.interaction)',
  'IGuild.members': '.members.cache',
  'IGuildMemberAddEvent.user': '.member.user!',
  'IInteractionEvent.interaction': '',
  'IInteractionEventWithAcknowledge.interaction': '',
  'IInteractions.events': '',
  'IMember.boostingSince': '.premiumSince',
  'IMember.nickname': '.nick',
  'IMentionableMultiSelectInteractionEvent.interaction': '',
  'IMessage.client': '.manager.client',
  'IMinimalGuildChannel.parentChannel': '.parent',
  'IModalInteraction.components': '.data.components',
  'IModalInteraction.customId': '.data.customId',
  'IModalInteraction.memberAuthor': '.member',
  'IModalInteraction.userAuthor': '.user',
  'IModalInteractionEvent.interaction': '',
  'IMultiselectInteraction.memberAuthor': '.member',
  'IMultiselectInteraction.userAuthor': '.user',
  'IMultiselectInteraction.values': '.data.values!',
  'IMultiselectInteractionEvent.interaction': '',
  'INyxx.channels': '.channels.cache',
  'INyxx.guilds': '.guilds.cache',
  'INyxx.httpEndpoints': '',
  'INyxx.users': '.users.cache',
  'INyxxRest.httpEndpoints': '',
  'INyxxWebsocket.appId': '.application.id',
  'INyxxWebsocket.eventsRest': '.httpHandler',
  'INyxxWebsocket.eventsWs': '',
  'INyxxWebsocket.httpEndpoints': '',
  'INyxxWebsocket.shardManager': '.gateway',
  'INyxxWebsocket.shards': '.gateway.totalShards',
  'IPermissions.raw': '.value',
  'IReferencedMessage.message': '',
  'IRoleMultiSelectInteractionEvent.interaction': '',
  'IShardManager.gatewayLatency': '.latency',
  'IShardManager.totalNumShards': '.totalShards',
  'ISlashCommand.options': '.options!',
  'ISlashCommandInteraction.commandId': '.data.id',
  'ISlashCommandInteraction.memberAuthor': '.member',
  'ISlashCommandInteraction.resolved': '.data.resolved',
  'ISlashCommandInteraction.targetId': '.data.targetId',
  'ISlashCommandInteraction.userAuthor': '.user',
  'ISlashCommandInteractionEvent.args': '.data.options!',
  'ISlashCommandInteractionEvent.interaction': '',
  'ISlashCommandPermissionOverrides.permissionOverrides': '.permissions',
  'ITextChannel.messageCache': '.messages.cache',
  'IUser.dmChannel': '.manager.createDm(user.id)',
  'IUser.tag': '.REMOVED_tag',
  'IUserMultiSelectInteractionEvent.interaction': '',
  'IWebsocketEventController.onDmReceived':
      '.onMessageCreate.where((event) => event.guild == null)',
  'IWebsocketEventController.onMessageReactionAdded': '.onMessageReactionAdd',
  'IWebsocketEventController.onMessageReceived': '.onMessageCreate',
  'Locale.code': '.identifier',
  'MemberBuilder.channel': '.voiceChannelId',
  'MessageBuilder.clearCharacter': "'‎'",
  'SlashCommandPermissionOverride.allowed': '.hasPermission',
  'SlashCommandPermissionType.channel': 'CommandPermissionType.channel',
  'SlashCommandPermissionType.role': 'CommandPermissionType.role',
  'SlashCommandPermissionType.user': 'CommandPermissionType.user',
  'SlashCommandType.chat': 'ApplicationCommandType.chatInput',
  'SlashCommandType.message': 'ApplicationCommandType.message',
  'SlashCommandType.user': 'ApplicationCommandType.user',
  'Snowflake.id': '.value',
  'SnowflakeEntity.createdAt': '.id.timestamp',
};

// Override visitXXX() methods to replace the content of XXX nodes.
class NyxxRewriter extends GeneralizingAstVisitor<String> {
  /// Returns the original source contained in [node].
  @override
  String visitNode(AstNode node) {
    final result = StringBuffer();
    final root = node.root as CompilationUnit;
    final source = root.declaredElement!.source.contents.data;

    var lastEnd = node.offset;

    for (final child in node.childEntities) {
      if (child.offset < lastEnd) {
        // Is it OK to skip here?
        // This seems to occur mostly in comments and in field declarations which have comments.
        continue;
      } else if (lastEnd != child.offset) {
        result.write(source.substring(lastEnd, child.offset));
      }

      if (child is Token) {
        result.write(source.substring(child.offset, child.end));
      } else {
        result.write((child as AstNode).accept(this)!);
      }

      lastEnd = child.end;
    }

    if (node == root && lastEnd != source.length) {
      result.write(source.substring(lastEnd));
    }

    return result.toString();
  }

  String? _replaceAccess(
    Expression? target,
    DartType? targetType,
    Identifier property, {
    bool isCascaded = false,
  }) {
    final element = property.staticElement;
    final isStatic = (element is ClassMemberElement && element.isStatic) ||
        (element is ExecutableElement &&
            element.isStatic &&
            element.enclosingElement is ClassElement);

    if (isStatic) {
      final type = (target as Identifier).staticElement as ClassElement;
      final mapped = mapping['${type.name}.${property.name}'];

      if (mapped != null &&
          type.location!.encoding.startsWith(RegExp(r'package:nyxx(_interactions|_commands)?/'))) {
        return mapped;
      }
    } else if (targetType?.element != null) {
      final type = targetType!.element!;
      final mapped = mapping['${type.name}.${property.name}'];

      if (mapped != null &&
          type.location!.encoding.startsWith(RegExp(r'package:nyxx(_interactions|_commands)?/'))) {
        return '${isCascaded ? '.' : target?.accept(this) ?? ''}$mapped';
      }
    }

    return null;
  }

  String? _replaceInvocation(
    AstNode target,
    String methodIdentifier,
    ArgumentList arguments, {
    required bool isStatic,
    bool isCascaded = false,
  }) {
    final replacement = mapping['$methodIdentifier()'];

    if (replacement == null) {
      return null;
    }

    final substitutedReplacement = replacement.replaceAllMapped(
      RegExp(r'\{([\d\w]+)\}'),
      (match) {
        final id = int.tryParse(match.group(1)!);

        if (id == 0) {
          return isCascaded ? '.' : target.accept(this)!;
        } else if (id != null) {
          return arguments.arguments[id - 1].accept(this)!;
        }

        return (arguments.arguments
                    .where((element) =>
                        element is NamedExpression && element.name.label.name == match.group(1)!)
                    .firstOrNull as NamedExpression?)
                ?.expression
                .accept(this) ??
            'null';
      },
    );

    return substitutedReplacement;
  }

  @override
  String visitImportDirective(ImportDirective node) {
    if (node.uri.stringValue == 'package:nyxx_interactions/nyxx_interactions.dart') {
      if ((node.root as CompilationUnit)
          .directives
          .whereType<ImportDirective>()
          .any((element) => element.uri.stringValue == 'package:nyxx/nyxx.dart')) {
        return '';
      }

      return "import 'package:nyxx/nyxx.dart';";
    }

    return super.visitImportDirective(node)!;
  }

  @override
  String visitPropertyAccess(PropertyAccess node) {
    return _replaceAccess(node.target, node.realTarget.staticType, node.propertyName,
            isCascaded: node.isCascaded) ??
        super.visitPropertyAccess(node)!;
  }

  @override
  String visitPrefixedIdentifier(PrefixedIdentifier node) {
    return _replaceAccess(node.prefix, node.prefix.staticType, node.identifier) ??
        super.visitPrefixedIdentifier(node)!;
  }

  @override
  String visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.staticElement?.location?.encoding
            .startsWith(RegExp(r'package:nyxx(_interactions|_commands)?/')) !=
        true) {
      return super.visitMethodInvocation(node)!;
    }

    if (node.methodName.staticElement case ClassMemberElement element when element.isStatic) {
      final type = node.realTarget as Identifier;

      final replacement = _replaceInvocation(
        type,
        '${type.staticElement!.name}.${node.methodName.name}',
        node.argumentList,
        isStatic: true,
        isCascaded: node.isCascaded,
      );

      if (replacement != null) {
        return replacement;
      }
    } else if (node.realTarget?.staticType != null) {
      final type = node.realTarget!.staticType!.element!;

      final replacement = _replaceInvocation(
        node.realTarget!,
        '${type.name}.${node.methodName.name}',
        node.argumentList,
        isStatic: false,
        isCascaded: node.isCascaded,
      );

      if (replacement != null) {
        return replacement;
      }
    }

    return super.visitMethodInvocation(node)!;
  }

  @override
  String visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.staticElement?.library.location!.encoding
            .startsWith(RegExp(r'package:nyxx(_interactions|_commands)?/')) !=
        true) {
      return super.visitInstanceCreationExpression(node)!;
    }

    final replacement = _replaceInvocation(
      node.constructorName.type,
      '${node.constructorName.type.element!.name}.${node.constructorName.name?.name ?? 'new'}',
      node.argumentList,
      isStatic: true,
    );

    return replacement ?? super.visitInstanceCreationExpression(node)!;
  }

  @override
  String visitNamedType(NamedType node) {
    final type = node.type;
    if (type is! InterfaceType ||
        !type.element.library.location!.encoding
            .startsWith(RegExp(r'package:nyxx(_interactions|_commands)?/'))) {
      return super.visitNamedType(node)!;
    }

    final name = type.element.name;
    return '${node.importPrefix?.accept(this) ?? ''}'
        '${mapping[name] ?? name}'
        '${node.typeArguments?.accept(this) ?? ''}'
        '${type.nullabilitySuffix == NullabilitySuffix.question ? '?' : ''}';
  }
}
